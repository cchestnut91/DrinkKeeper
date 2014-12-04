//
//  AppDelegate.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AppDelegate.h"
#import "StoredDataManager.h"
#import "JNKeychain.h"
#import <Crashlytics/Crashlytics.h>
#import "Drink.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSDictionary *launchParams;
    NSSet *objectTypes;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Transfers any saved keychain values from previous versions
    [self clearKeychain];
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]){
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if ([[url absoluteString] containsString:@"?"]){
            NSDictionary *params = [self getParamsFromURL:url];
            
            if ([params objectForKey:@"type"]){
                launchParams = params;
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(openLaunchURL:)
                                                             name:@"checkLaunchURL"
                                                           object:nil];
            }
        }
    }
    
    [Crashlytics startWithAPIKey:@"6e63974ab6878886d46e46575c43005ded0cfa08"];
    return YES;
}

-(void)clearKeychain{
    if ([JNKeychain loadValueForKey:@"weight"]){
        [[StoredDataManager sharedInstance] setValue:[JNKeychain loadValueForKey:@"weight"]
                                              forKey:[StoredDataManager weightKey]];
    }
    if ([JNKeychain loadValueForKey:@"sex"]){
        [[StoredDataManager sharedInstance] setValue:[JNKeychain loadValueForKey:@"sex"]
                                              forKey:[StoredDataManager sexKey]];
    }
    
    [JNKeychain deleteValueForKey:@"weight"];
    [JNKeychain deleteValueForKey:@"sex"];
}

-(void)openLaunchURL:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"checkLaunchURL"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addFromURL"
                                                        object:nil
                                                      userInfo:launchParams];
}

-(NSDictionary *)getParamsFromURL:(NSURL *)url{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    
    NSString *params = [[url absoluteString] componentsSeparatedByString:@"?"][1];
    NSArray *groups = [params componentsSeparatedByString:@"&"];
    for (NSString *group in groups){
        [ret setObject:[group componentsSeparatedByString:@"="][1]
                forKey:[group componentsSeparatedByString:@"="][0]];
    }
    
    return ret;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    double bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [[HealthKitManager sharedInstance] saveBacWithValue:bac];

    completionHandler(UIBackgroundFetchResultNewData);
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([[url absoluteString] containsString:@"?"]){
        NSDictionary *params = [self getParamsFromURL:url];
        
        if ([params objectForKey:@"type"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addFromURL"
                                                                object:nil
                                                              userInfo:params];
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[HealthKitManager sharedInstance] updateHealthValues];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
