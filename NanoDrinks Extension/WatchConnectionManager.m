//
//  WatchConnectionManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/3/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "WatchConnectionManager.h"

@implementation WatchConnectionManager

static WatchConnectionManager *sharedObject;

+ (instancetype)sharedInstance {
    if (sharedObject == nil) {
        sharedObject = [[WatchConnectionManager alloc] init];
        
        // Do stuff
        [[WCSession defaultSession] setDelegate:sharedObject];
        [[WCSession defaultSession] activateSession];
    }
    
    return sharedObject;
}

-(void)updateContext:(NSDictionary *)newContext {
    [super updateContext:newContext];
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    [super session:session didReceiveMessage:message];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    [super session:session didReceiveApplicationContext:applicationContext];
}

- (void)updateComplication {
    NSArray *complications = [[CLKComplicationServer sharedInstance] activeComplications];
    for (CLKComplication *complication in complications) {
        [[CLKComplicationServer sharedInstance] reloadTimelineForComplication:complication];
    }
}

@end
