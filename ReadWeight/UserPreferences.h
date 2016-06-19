//
//  UserPreferences.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/12/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPreferences : NSObject

+ (instancetype) sharedInstance;

- (void)updateWithContext:(NSDictionary *)dictionary;

- (BOOL)allowsNotifications;
- (void)setAllowsNotifcation:(BOOL)allowsNotifcation;

- (BOOL)prefersMetric;
- (void)setPrefersMetric:(BOOL)prefersMetric;

- (BOOL)hasShownShakeInfo;
- (void)setHasShownShakeInfo:(BOOL)shakeShown;

- (BOOL)hasSyncedWatchApp;
- (void)setHasSyncedWatchApp:(BOOL)watchSynced;

- (BOOL)requestsReminders;
- (NSTimeInterval)updateInterval;
- (void)setUpdateInterval:(NSTimeInterval)updateInterval;

- (NSDate *)verTwoUpdated;

@end
