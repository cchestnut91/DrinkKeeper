//
//  AppDelegate.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AppDelegate.h"
#import <Crashlytics/Crashlytics.h>
#import "Drink.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSDictionary *launchParams;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    if (self.healthStore == nil){
        self.healthStore = [[HKHealthStore alloc] init];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]){
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        if ([[url absoluteString] containsString:@"?"]){
            NSDictionary *params = [self getParamsFromURL:url];
            
            if ([params objectForKey:@"type"]){
                launchParams = params;
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLaunchURL:) name:@"checkLaunchURL" object:nil];
            }
        }
    }
    
    [Crashlytics startWithAPIKey:@"6e63974ab6878886d46e46575c43005ded0cfa08"];
    return YES;
}

-(void)openLaunchURL:(NSNotification *)notification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"checkLaunchURL" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"addFromURL" object:nil userInfo:launchParams];
}

-(NSDictionary *)getParamsFromURL:(NSURL *)url{
    NSMutableDictionary *ret = [[NSMutableDictionary alloc] init];
    
    NSString *params = [[url absoluteString] componentsSeparatedByString:@"?"][1];
    NSArray *groups = [params componentsSeparatedByString:@"&"];
    for (NSString *group in groups){
        [ret setObject:[group componentsSeparatedByString:@"="][1] forKey:[group componentsSeparatedByString:@"="][0]];
    }
    
    return ret;
}

-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
    if (self.healthStore == nil){
        self.healthStore = [[HKHealthStore alloc] init];
    }
    
    double bac = 0.0;
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"];
    NSString *bacFile = [[containerURL URLByAppendingPathComponent:@"bac"] path];
    NSString *sessionFile = [[containerURL URLByAppendingPathComponent:@"drinkingSession"] path ];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]){
        
        NSDictionary *drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:sessionFile];
        NSArray *drinks = [drinkingSession objectForKey:@"drinks"];
        double consumed = 0.0;
        for (Drink *drink in drinks){
            double add = [[drink multiplier] doubleValue];
            consumed += add;
        }
        consumed = consumed * 0.806 * 1.2;
        double genderStandard = [self genderStandard];
        double kgweight =([[JNKeychain loadValueForKey:@"weight"] doubleValue] * 0.454);
        double weightMod = genderStandard * kgweight;
        double newBac = consumed / weightMod;
        double hoursDrinking = [[NSDate date] timeIntervalSinceDate:[drinkingSession objectForKey:@"startTime"]] / 60.0 / 60.0;
        double metabolized = [self metabolismConstant] * hoursDrinking;
        bac = newBac - metabolized;
        if (bac <= 0.0){
            [[NSFileManager defaultManager] removeItemAtPath:sessionFile error:nil];
            bac = 0.0;
        }
    }
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    HKQuantitySample *bacSample = [HKQuantitySample quantitySampleWithType:type quantity:[HKQuantity quantityWithUnit:[HKUnit percentUnit] doubleValue:bac / 100] startDate:[NSDate date] endDate:[NSDate date]];
    [self.healthStore saveObject:bacSample withCompletion:nil];
    [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:bac] toFile:bacFile];

    completionHandler(UIBackgroundFetchResultNewData);
}

-(double)metabolismConstant{
    NSInteger sex = [[JNKeychain loadValueForKey:@"sex"] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.015;
    } else if (sex == HKBiologicalSexFemale){
        return 0.017;
    } else {
        return 0.016;
    }
}

-(double)genderStandard{
    NSInteger sex = [[JNKeychain loadValueForKey:@"sex"] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.58;
    } else if (sex == HKBiologicalSexFemale){
        return 0.49;
    } else {
        return 0.535;
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([[url absoluteString] containsString:@"?"]){
        NSDictionary *params = [self getParamsFromURL:url];
        
        if ([params objectForKey:@"type"]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addFromURL" object:nil userInfo:params];
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
