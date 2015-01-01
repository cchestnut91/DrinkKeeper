//
//  ExtensionDelegate.m
//  NanoDrinks Extension
//
//  Created by Calvin Chestnut on 8/28/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "ExtensionDelegate.h"

#import "WatchConnectionManager.h"
#import "HealthKitManager.h"

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching {
    // Perform any final initialization of your application.
    [[WatchConnectionManager sharedInstance] watchAppDidLaunch];

}

- (void)applicationDidBecomeActive {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[WatchConnectionManager sharedInstance] watchAppDidLaunch];
    [[HealthKitManager sharedInstance] updateHealthValues];
}

- (void)applicationWillResignActive {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, etc.
}

@end
