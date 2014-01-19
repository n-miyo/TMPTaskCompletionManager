// -*- mode:objc -*-

#import "Kiwi.h"

#import "TMPTaskCompletionManager.h"

@interface TMPTaskCompletionManager(TestSupport)
@property (nonatomic) NSMutableArray *taskIdentifiers;
@property (nonatomic) NSMutableArray *eTasks;
@property (nonatomic) NSOperationQueue *defaultTaskQueue;

- (void)applicationWillTerminate;
@end

SPEC_BEGIN(TMPTaskCompletionManagerSpec)

typedef void (^task_t)();

describe(@"TMPTaskCompletionManagerSpec", ^{
  context(@"for calling runBackgroundTask:taskQueue:expirationTask", ^{
    __block TMPTaskCompletionManager *taskCompletion;

    beforeEach(^{
        taskCompletion = [TMPTaskCompletionManager sharedManager];
        taskCompletion.taskIdentifiers = nil;
        taskCompletion.eTasks = nil;
      });

    it(@"should register specified task to defaultQueue.", ^{
        NSOperationQueue *dQ = [NSOperationQueue mock];
        taskCompletion.defaultTaskQueue = dQ;

        task_t t0 = ^{};
        task_t t1 = ^{};
        task_t e0 = ^{};
        task_t e1 = ^{};
        UIBackgroundTaskIdentifier btid;

        [[dQ should]
          receive:@selector(addOperation:)
          withCount:2];

        btid = [taskCompletion
          runBackgroundTask:t0
                  taskQueue:nil
             expirationTask:e0];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(1)];
        [[taskCompletion.taskIdentifiers[0] should] equal:@(btid)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(1)];

        btid = [taskCompletion
          runBackgroundTask:t1
                  taskQueue:nil
             expirationTask:e1];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(2)];
        [[taskCompletion.taskIdentifiers[1] should] equal:@(btid)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(2)];
    });

    it(@"should register specified task to specified queue.", ^{
        NSOperationQueue *dQ = [NSOperationQueue mock];
        taskCompletion.defaultTaskQueue = dQ;
        NSOperationQueue *mQ = [NSOperationQueue mock];

        task_t t0 = ^{};
        task_t t1 = ^{};
        task_t e0 = ^{};
        task_t e1 = ^{};
        UIBackgroundTaskIdentifier btid;

        [[dQ should]
          receive:@selector(addOperation:)
          withCount:0];
        [[mQ should]
          receive:@selector(addOperation:)
          withCount:2];

        btid = [taskCompletion
          runBackgroundTask:t0
                  taskQueue:mQ
             expirationTask:e0];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(1)];
        [[taskCompletion.taskIdentifiers[0] should] equal:@(btid)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(1)];

        btid = [taskCompletion
          runBackgroundTask:t1
                  taskQueue:mQ
             expirationTask:e1];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(2)];
        [[taskCompletion.taskIdentifiers[1] should] equal:@(btid)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(2)];
    });
  });

  context(@"for calling runBackgroundOperation:taskQueue:expirationTask", ^{
    __block TMPTaskCompletionManager *taskCompletion;

    beforeEach(^{
        taskCompletion = [TMPTaskCompletionManager sharedManager];
        taskCompletion.taskIdentifiers = nil;
        taskCompletion.eTasks = nil;
      });

    it(@"should cancel eTask if operation finished correctly.", ^{
        taskCompletion.defaultTaskQueue = [NSOperationQueue new];

        __block NSString *o0Expired = nil;
        NSBlockOperation *o0 =
          [NSBlockOperation blockOperationWithBlock:^{
              [NSThread sleepForTimeInterval:1];
              o0Expired = @"done";
            }];
        task_t e0 = ^{o0Expired = @"expired";};

        __block NSString *o1Expired = nil;
        NSBlockOperation *o1 =
          [NSBlockOperation blockOperationWithBlock:^{
              [NSThread sleepForTimeInterval:3];
              o1Expired = @"done";
            }];
        task_t e1 = ^{o1Expired = @"expired";};

        UIBackgroundTaskIdentifier btid;
        btid = [taskCompletion
          runBackgroundOperation:o0
                       taskQueue:nil
                  expirationTask:e0];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(1)];
        [[taskCompletion.taskIdentifiers[0] should] equal:@(btid)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(1)];

        btid = [taskCompletion
          runBackgroundOperation:o1
                  taskQueue:nil
             expirationTask:e1];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(2)];
        [[taskCompletion.taskIdentifiers[1] should] equal:@(btid)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(2)];

        [[expectFutureValue(theValue([taskCompletion.eTasks count]))
             shouldEventuallyBeforeTimingOutAfter(2.0)]
          equal:theValue(1)];
        [[expectFutureValue(o0Expired)
             shouldEventuallyBeforeTimingOutAfter(2.0)]
          equal:@"done"];

        [[expectFutureValue(theValue([taskCompletion.eTasks count]))
             shouldEventuallyBeforeTimingOutAfter(4.0)]
          equal:theValue(0)];
        [[expectFutureValue(o1Expired)
             shouldEventuallyBeforeTimingOutAfter(4.0)]
          equal:@"done"];
    });

    it(@"should invoke eTask if operation did not finish.", ^{
        taskCompletion.defaultTaskQueue = [NSOperationQueue new];

        __block NSString *o0Expired = nil;
        NSBlockOperation *o0 =
          [NSBlockOperation blockOperationWithBlock:^{
              [NSThread sleepForTimeInterval:5];
              o0Expired = @"done";
            }];
        task_t e0 = ^{o0Expired = @"expired";};

        __block NSString *o1Expired = nil;
        NSBlockOperation *o1 =
          [NSBlockOperation blockOperationWithBlock:^{
              [NSThread sleepForTimeInterval:5];
              o1Expired = @"done";
            }];
        task_t e1 = ^{o1Expired = @"expired";};

        [taskCompletion
          runBackgroundOperation:o0
                       taskQueue:nil
                  expirationTask:e0];
        [taskCompletion
          runBackgroundOperation:o1
                  taskQueue:nil
             expirationTask:e1];

        [taskCompletion applicationWillTerminate];

        [[expectFutureValue(o0Expired)
             shouldEventually]
          equal:@"expired"];
        [[expectFutureValue(o1Expired)
             shouldEventually]
          equal:@"expired"];
    });
  });

  context(@"for calling cancelBackgroundTask", ^{
    __block TMPTaskCompletionManager *taskCompletion;

    beforeEach(^{
        taskCompletion = [TMPTaskCompletionManager sharedManager];
        taskCompletion.taskIdentifiers = nil;
        taskCompletion.eTasks = nil;
      });

    it(@"should ignore if there no registered task.", ^{
        UIApplication *a = [UIApplication sharedApplication];
        [[a shouldEventually]
          receive:@selector(endBackgroundTask:)
          withCount:0];
        [taskCompletion cancelBackgroundTask:1];
    });

    it(@"should ignore if specified task is not registered.", ^{
        UIApplication *a = [UIApplication sharedApplication];
        [taskCompletion.taskIdentifiers addObject:@(1)];
        [taskCompletion.eTasks addObject:@"foo"];
        [[a shouldEventually]
          receive:@selector(endBackgroundTask:)
          withCount:0];
        [taskCompletion cancelBackgroundTask:2];
    });

    it(@"should cancel specified task.", ^{
        UIApplication *a = [UIApplication sharedApplication];
        [taskCompletion.taskIdentifiers addObject:@(1)];
        [taskCompletion.taskIdentifiers addObject:@(2)];
        [taskCompletion.eTasks addObject:@"foo"];
        [taskCompletion.eTasks addObject:@"bar"];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(2)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(2)];

        [[a shouldEventually]
          receive:@selector(endBackgroundTask:)
          withCount:1];
        [taskCompletion cancelBackgroundTask:1];
        [[expectFutureValue(theValue([taskCompletion.taskIdentifiers count]))
             shouldEventually] equal:theValue(1)];
        [[expectFutureValue(taskCompletion.taskIdentifiers[0])
             shouldEventually] equal:@(2)];
        [[expectFutureValue(taskCompletion.eTasks[0])
             shouldEventually] equal:@"bar"];
    });
  });

  context(@"for calling cancelAllBackgroundTasks", ^{
    __block TMPTaskCompletionManager *taskCompletion;

    beforeEach(^{
        taskCompletion = [TMPTaskCompletionManager sharedManager];
        taskCompletion.taskIdentifiers = nil;
        taskCompletion.eTasks = nil;
      });

    it(@"should ignore if there no registered task.", ^{
        UIApplication *a = [UIApplication sharedApplication];
        [[a should]
          receive:@selector(endBackgroundTask:)
          withCount:0];
        [taskCompletion cancelAllBackgroundTasks];
    });

    it(@"should cancel all registered tasks.", ^{
        UIApplication *a = [UIApplication sharedApplication];
        [taskCompletion.taskIdentifiers addObject:@(1)];
        [taskCompletion.taskIdentifiers addObject:@(2)];
        [taskCompletion.eTasks addObject:@"foo"];
        [taskCompletion.eTasks addObject:@"bar"];
        [[theValue([taskCompletion.taskIdentifiers count])
             should] equal:theValue(2)];
        [[theValue([taskCompletion.eTasks count])
             should] equal:theValue(2)];

        [[a shouldEventually]
          receive:@selector(endBackgroundTask:)
          withCount:2];
        [taskCompletion cancelAllBackgroundTasks];
        [[expectFutureValue(theValue([taskCompletion.taskIdentifiers count]))
             shouldEventually] equal:theValue(0)];
        [[expectFutureValue(theValue([taskCompletion.eTasks count]))
             shouldEventually] equal:theValue(0)];
    });
  });
});

SPEC_END

// EOF
