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

- (BOOL)prefersMetric;
- (void)setPrefersMetric:(BOOL)prefersMetric;

- (BOOL)hasShownShakeInfo;
- (void)setHasShownShakeInfo:(BOOL)shakeShown;

- (BOOL)hasSyncedWatchApp;
- (void)setHasSyncedWatchApp:(BOOL)watchSynced;

- (NSDate *)verTwoUpdated;

@end
