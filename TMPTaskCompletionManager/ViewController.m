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

#import "ViewController.h"

#import "AppDelegate.h"
#import "TMPTaskCompletionManager.h"

@interface ViewController ()
@property (nonatomic) NSDate *baseDate;
@property (nonatomic, readonly) NSInteger count;
@property (nonatomic) BOOL badgeNumber;
@property (nonatomic) UIBackgroundTaskIdentifier badgeNumberId;
@property (nonatomic) BOOL localNotification;
@property (nonatomic) UIBackgroundTaskIdentifier localNotificationId;
@end

@implementation ViewController

#pragma mark - properties

- (NSInteger)count
{
  return [[NSDate date] timeIntervalSinceDate:self.baseDate];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.baseDate = [NSDate date];
  [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

- (IBAction)changeStateOnActiveSwitch:(UISwitch *)sender
{
  AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
  appDelegate.clearAtDidBecomeActive = sender.on;
}

- (IBAction)changeStateOnBadgeNumberSwitch:(UISwitch *)sender
{
  if (self.badgeNumber) {
    [[TMPTaskCompletionManager sharedManager]
      cancelBackgroundTask:self.badgeNumberId];
  }

  self.badgeNumber = sender.on;
  if (self.badgeNumber) {
    self.badgeNumberId =
      [[TMPTaskCompletionManager sharedManager]
        runBackgroundTask:^{
          UIApplication *application = [UIApplication sharedApplication];
          while (self.badgeNumber) {
            application.applicationIconBadgeNumber = self.count;
            sleep(1);
          }
        }
        taskQueue:nil
        expirationTask:^{
          NSLog(@"BadgeNumber task expired");
        }];
  }
}

- (IBAction)changeStateOnNotificationSwitch:(UISwitch *)sender
{
  if (self.localNotification) {
    [[TMPTaskCompletionManager sharedManager]
      cancelBackgroundTask:self.localNotificationId];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
  }

  self.localNotification = sender.on;
  if (self.localNotification) {
    UILocalNotification *notification = [UILocalNotification new];
    notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.alertAction = @"Open";

    self.localNotificationId =
      [[TMPTaskCompletionManager sharedManager]
        runBackgroundTask:^{
          while (self.localNotification) {
            if ((self.count % 10) == 0) {
              notification.alertBody =
                [NSString stringWithFormat:@"Notification: %ld",
                        (long)self.count];
              [[UIApplication sharedApplication]
                scheduleLocalNotification:notification];
            }
            sleep(1);
          }
        }
        taskQueue:nil
        expirationTask:^{
          NSLog(@"BadgeNumber task expired");
        }];
  }
}

@end

// EOF
