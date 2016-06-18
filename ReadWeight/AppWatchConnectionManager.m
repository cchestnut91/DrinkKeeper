//
//  WatchConnectionManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 8/31/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "AppWatchConnectionManager.h"

@implementation AppWatchConnectionManager

static AppWatchConnectionManager *sharedObject;

+ (AppWatchConnectionManager *)sharedInstance {
    if (sharedObject == nil) {
        sharedObject = [AppWatchConnectionManager privateInit];
    }
    
    return sharedObject;
}

+ (AppWatchConnectionManager *)privateInit {
    AppWatchConnectionManager *instance = [[AppWatchConnectionManager alloc] init];
    
    return instance;
}

-(void)updateContext:(NSDictionary *)newContext {
    NSError *error;
    [[WCSession defaultSession] updateApplicationContext:newContext error:&error];
    if (error) {
        NSLog(@"Error updating watch context: %@", error);
    } else {
        [(AppWatchConnectionManager *)[[WCSession defaultSession] delegate] updateComplication];
    }
}

- (void)appDidLaunch {
    WCSession *session = [WCSession defaultSession];
    if ([[session receivedApplicationContext] count]) {
        [self session:[WCSession defaultSession] didReceiveApplicationContext:[[WCSession defaultSession] receivedApplicationContext]];
    }
}

- (void)watchAppDidLaunch {
    WCSession *session = [WCSession defaultSession];
    if ([[session receivedApplicationContext] count]) {
        [self session:[WCSession defaultSession] didReceiveApplicationContext:[[WCSession defaultSession] receivedApplicationContext]];
    }
}

- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *,id> *)message {
    [[StoredDataManager sharedInstance] handleMessage:message];
}

- (void)session:(WCSession *)session didReceiveApplicationContext:(NSDictionary<NSString *,id> *)applicationContext {
    [[StoredDataManager sharedInstance] handleContext:applicationContext];
}

- (void)session:(WCSession *)session didReceiveUserInfo:(NSDictionary<NSString *,id> *)userInfo {
    [self session:session didReceiveApplicationContext:userInfo];
}

- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(NSError *)error
{
    
}

- (void)updateComplication {
    // No super imp
    NSLog(@"No OP");
}

@end
