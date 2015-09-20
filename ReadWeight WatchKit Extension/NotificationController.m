//
//  NotificationController.m
//  ReadWeight WatchKit Extension
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "NotificationController.h"

#import <UIKit/UIKit.h>


@interface NotificationController()

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ init", self);
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
}

- (void)didReceiveLocalNotification:(UILocalNotification *)localNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    
    NSDictionary *sessionInfo = [[localNotification userInfo] objectForKey:@"sessionInfo"];
    
    if (sessionInfo){
        [[self sessionInfoGroup] setHidden:NO];
        [self.titleLabel setText:@"BAC has reached 0.0\n\nSession Details:"];
        
        [self.durationLabel setText:[sessionInfo objectForKey:@"duration"]];
        [self.drinksLabel setText:[sessionInfo objectForKey:@"numDrinks"]];
        [self.peakLabel setText:[sessionInfo objectForKey:@"peakBAC"]];
        
        completionHandler(WKUserNotificationInterfaceTypeCustom);
    } else {
        completionHandler(WKUserNotificationInterfaceTypeDefault);
    }
}

- (void)didReceiveRemoteNotification:(NSDictionary *)remoteNotification withCompletion:(void (^)(WKUserNotificationInterfaceType))completionHandler {
    
    NSDictionary *sessionInfo = [remoteNotification objectForKey:@"sessionInfo"];
    if (sessionInfo){
        [[self sessionInfoGroup] setHidden:NO];
        [self.titleLabel setText:@"BAC has reached 0.0\n\nSession Details:"];
        
        [self.durationLabel setText:[sessionInfo objectForKey:@"duration"]];
        [self.drinksLabel setText:[sessionInfo objectForKey:@"numDrinks"]];
        [self.peakLabel setText:[sessionInfo objectForKey:@"peakBAC"]];
        
        completionHandler(WKUserNotificationInterfaceTypeCustom);
    } else {
        completionHandler(WKUserNotificationInterfaceTypeDefault);
    }
}

@end



