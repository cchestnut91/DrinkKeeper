//
//  WatchConnectionManager.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 8/31/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <WatchConnectivity/WatchConnectivity.h>

#import "StoredDataManager.h"

@interface AppWatchConnectionManager : NSObject <WCSessionDelegate>

+(AppWatchConnectionManager *)sharedInstance;
+ (AppWatchConnectionManager *)privateInit;

-(void)updateContext:(NSDictionary *)newContext;

- (void)updateComplication;

- (void)appDidLaunch;
- (void)watchAppDidLaunch;

@end
