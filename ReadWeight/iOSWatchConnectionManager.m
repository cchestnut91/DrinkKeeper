//
//  iOSWatchConnectionManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/15/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "iOSWatchConnectionManager.h"

#import "StoredDataManager.h"

@implementation iOSWatchConnectionManager

static iOSWatchConnectionManager *sharedObject;

+ (instancetype)sharedInstance {
    if (sharedObject == nil) {
        sharedObject = [[iOSWatchConnectionManager alloc] init];
        
        // Do stuff
        [[WCSession defaultSession] setDelegate:sharedObject];
        [[WCSession defaultSession] activateSession];
    }
    
    return sharedObject;
}

- (void)updateComplication {
    [[WCSession defaultSession] transferCurrentComplicationUserInfo:[[StoredDataManager sharedInstance] watchContext]];
}

@end
