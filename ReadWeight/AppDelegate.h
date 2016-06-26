//
//  AppDelegate.h
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>
#import <UserNotifications/UserNotifications.h>
#import "HealthKitManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
- (BOOL)watchAppNeedsSync;
-(void)registerNotifications;

@end

