// -*- mode:objc -*-
//
// Copyright (c) 2013 MIYOKAWA, Nobuyoshi (http://www.tempus.org/)
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.

#import "TMPTaskCompletionManager.h"

typedef void (^task_t)();

@interface TMPTaskCompletionManager()
@property (nonatomic) NSMutableArray *taskIdentifiers;
@property (nonatomic) NSMutableArray *eTasks;
@property (nonatomic) NSMutableDictionary *kvoAssigners;
@property (nonatomic) NSOperationQueue *defaultTaskQueue;
@end

@implementation TMPTaskCompletionManager

#pragma mark - properties

- (NSMutableArray *)taskIdentifiers
{
  if (!_taskIdentifiers) {
    _taskIdentifiers = [NSMutableArray new];
  }

  return _taskIdentifiers;
}

- (NSMutableArray *)eTasks
{
  if (!_eTasks) {
    _eTasks = [NSMutableArray new];
  }

  return _eTasks;
}

- (NSMutableDictionary *)kvoAssigners
{
  if (!_kvoAssigners) {
    _kvoAssigners = [NSMutableDictionary new];
  }

  return _kvoAssigners;
}

- (NSOperationQueue *)defaultTaskQueue
{
  if (!_defaultTaskQueue) {
    _defaultTaskQueue = [NSOperationQueue new];
  }

  return _defaultTaskQueue;
}

#pragma mark - object lifecycle

+ (instancetype)sharedManager
{
  static dispatch_once_t onceToken;
  static TMPTaskCompletionManager *taskCompletion;
  dispatch_once(&onceToken, ^{
    taskCompletion = [TMPTaskCompletionManager new];
  });

  return taskCompletion;
}

- (id)init
{
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(applicationWillTerminate)
             name:UIApplicationWillTerminateNotification
           object:nil];
  }

  return self;
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter]
    removeObserver:self
              name:UIApplicationWillTerminateNotification
            object:nil];
  for (NSOperation *op in [self.kvoAssigners allValues]) {
    [op removeObserver:self forKeyPath:@"isFinished"];
  }
}

#pragma mark - public

- (UIBackgroundTaskIdentifier)runBackgroundTask:(void (^)(void))task
                                      taskQueue:(NSOperationQueue *)taskQueue
                                 expirationTask:(void (^)(void))expirationTask
{
  __block UIBackgroundTaskIdentifier identifier;
  UIApplication *application = [UIApplication sharedApplication];
  task_t eTask = ^{
    if ([self.taskIdentifiers containsObject:@(identifier)]) {
      if (expirationTask) {
        expirationTask();
      }
      [self cancelBackgroundTask:identifier];
    }
  };
  identifier = [application beginBackgroundTaskWithExpirationHandler:eTask];
  [self.eTasks addObject:eTask];
  [self.taskIdentifiers addObject:@(identifier)];

  NSBlockOperation *bo =
    [NSBlockOperation blockOperationWithBlock:^{
        if (task) {
          task();
        }
        [self cancelBackgroundTask:identifier];
      }];
  if (taskQueue) {
    [taskQueue addOperation:bo];
  } else {
    [self.defaultTaskQueue addOperation:bo];
  }

  return identifier;
}

- (UIBackgroundTaskIdentifier)
runBackgroundOperation:(NSOperation *)operation
             taskQueue:(NSOperationQueue *)taskQueue
        expirationTask:(void (^)(void))expirationTask
{
  __block UIBackgroundTaskIdentifier identifier;
  UIApplication *application = [UIApplication sharedApplication];
  task_t eTask = ^{
    if ([self.taskIdentifiers containsObject:@(identifier)]) {
      if (expirationTask) {
        expirationTask();
      }
      [self cancelBackgroundTask:identifier];
    }
  };
  identifier = [application beginBackgroundTaskWithExpirationHandler:eTask];
  [self.eTasks addObject:eTask];
  [self.taskIdentifiers addObject:@(identifier)];

  if (operation) {
    [operation
      addObserver:self
       forKeyPath:@"isFinished"
          options:NSKeyValueObservingOptionNew
          context:(void *)identifier];
    self.kvoAssigners[@(identifier)] = operation;
    if (taskQueue) {
      [taskQueue addOperation:operation];
    } else {
      [self.defaultTaskQueue addOperation:operation];
    }
  }

  return identifier;
}

- (void)cancelBackgroundTask:(UIBackgroundTaskIdentifier)identifier
{
  UIApplication *application = [UIApplication sharedApplication];
  dispatch_async(dispatch_get_main_queue(), ^{
      NSUInteger index = [self.taskIdentifiers indexOfObject:@(identifier)];
      if (index != NSNotFound) {
        [application endBackgroundTask:identifier];
        [self.taskIdentifiers removeObjectAtIndex:index];
        [self.eTasks removeObjectAtIndex:index];
      }
    });
}

- (void)cancelAllBackgroundTasks
{
  UIApplication *application = [UIApplication sharedApplication];
  dispatch_async(dispatch_get_main_queue(), ^{
      for (NSInteger i = 0; i < [self.taskIdentifiers count]; i++) {
        [application
          endBackgroundTask:[self.taskIdentifiers[i] unsignedIntegerValue]];
      }
      self.taskIdentifiers = nil;
      self.eTasks = nil;
    });
}

#pragma mark - private

- (void)applicationWillTerminate
{
  for (NSInteger i = 0; i < [self.eTasks count]; i++) {
    ((task_t)self.eTasks[i])();
  }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
  if ([keyPath isEqualToString:@"isFinished"]) {
    UIBackgroundTaskIdentifier identifier =
      (UIBackgroundTaskIdentifier)context;
    NSOperation *operation = self.kvoAssigners[@(identifier)];
    [operation removeObserver:self forKeyPath:@"isFinished"];
    [self.kvoAssigners removeObjectForKey:@(identifier)];
    [self cancelBackgroundTask:identifier];
  }
}

@end

// EOF
