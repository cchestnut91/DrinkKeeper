//
//  WatchConnectionManager.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/3/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "AppWatchConnectionManager.h"

#import <ClockKit/ClockKit.h>

@interface WatchConnectionManager : AppWatchConnectionManager

+ (AppWatchConnectionManager *)sharedInstance;

@end
