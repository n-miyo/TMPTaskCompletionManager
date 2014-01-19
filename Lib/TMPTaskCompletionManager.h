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

@import Foundation;

/**
 The TMPTaskCompletionManager class provides functions for supporting
 task completion, especially for multiple background tasks.
 */
@interface TMPTaskCompletionManager : NSObject

/**
 Returns the singleton manager instance.

 @return The shared manager instance.
*/
+ (instancetype)sharedManager;

/**
 Register the specified task to run on the specified or default queue
 for background execution.  When the task is completed, background
 registration is automatically freed.  You can register multiple tasks
 with this method.  When 'applicationWillTerminate' event is received,
 expirationTasks are invoked for safe termination.

 @param task A task which runs in background.  This task is invoked on
 'taskQueue' or defaultQueue.
 @param taskQueue A queue on which runs 'task'.  If the value is nil,
 system automatically assigns default queue.
 @param expirationTask A task which runs if the task is not completed
 before allowed background second is expired.

 @return A unique identifier which is returned from system.
 */
- (UIBackgroundTaskIdentifier)runBackgroundTask:(void (^)(void))task
                                      taskQueue:(NSOperationQueue *)taskQueue
                                 expirationTask:(void (^)(void))expirationTask;

/**
 Register the specified operation to run on the specified or default
 queue for background execution.  Same as
 'runBackgroundTask:taskQueue:expirationTask:', but this method can
 accept NSOperation instead of block as the task.

 @param operation A operation which runs in background.  This task is
 invoked on 'taskQueue' or defaultQueue.
 @param taskQueue A queue on which runs 'operation'.  If the value is
 nil, system automatically assigns default queue.
 @param expirationTask A task which runs if the task is not completed
 before allowed background second is expired.

 @return A unique identifier which is returned from system.
 */
- (UIBackgroundTaskIdentifier)
runBackgroundOperation:(NSOperation *)operation
             taskQueue:(NSOperationQueue *)taskQueue
        expirationTask:(void (^)(void))expirationTask;

/**
 Unregister the task, which is specified with identifier, from
 background execution.  You have to call this method if the task does
 not need to run in background.

 @param identifier An identifier which
 runBackgroundTask:taskQueue:expirationTask: methods returned.
 */
- (void)cancelBackgroundTask:(UIBackgroundTaskIdentifier)identifier;

/**
 Unregister all task, which is registered with
 runBackgroundTask:taskQueue:expirationTask: methods.  You want to invoke
 this method such as in - [UIApplicationDelegate applicationDidBecomeActive:].
 */
- (void)cancelAllBackgroundTasks;

@end

// EOF
