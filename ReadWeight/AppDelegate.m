//
//  AppDelegate.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AppDelegate.h"
#import "StoredDataManager.h"
#import "iOSWatchConnectionManager.h"
#import "JNKeychain.h"
#import "Drink.h"

static NSString *sessionEndedNotificationCategory = @"sessionComplete";
static NSString *drinkReminderNotificationCategory = @"drinkReminder";

static NSString *showDetailsActionIdentifier = @"showDetails";
static NSString *saveActionIdentifier = @"saveToHealth";
static NSString *addDrinkActionIdentifier = @"addDrink";

static NSString *kSessionFileName = @"sessionFileName";

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    NSDictionary *launchParams;
    AddDrinkContext *context;
    NSSet *objectTypes;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //[Crashlytics startWithAPIKey:@"6e63974ab6878886d46e46575c43005ded0cfa08"];
    // Override point for customization after application launch.
    
    [[iOSWatchConnectionManager sharedInstance] appDidLaunch];
    
    
    [UserPreferences sharedInstance];
    
    if ([self watchAppNeedsSync]) {
        [[StoredDataManager sharedInstance] updateWatchContext];
    }
    
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    
    // Transfers any saved keychain values from previous versions
    [self clearKeychain];
    [self defineCategories];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateNotifications)
                                                 name:@"bacUpdated"
                                               object:nil];
	
    application.applicationSupportsShakeToEdit = YES;
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    NSString *key = shortcutItem.type;
    NSString *type;
    if ([key isEqualToString:@"com.calvinchestnut.drinkKeeper.shortcut.addBeer"]) {
        type = @"Beer";
    } else if ([key isEqualToString:@"com.calvinchestnut.drinkKeeper.shortcut.addWine"]) {
        type = @"Wine";
    } else if ([key isEqualToString:@"com.calvinchestnut.drinkKeeper.shortcut.addDrink"]) {
        type = @"Liquor";
    } else if ([key isEqualToString:@"com.calvinchestnut.drinkKeeper.shortcut.duplicate"]) {
        type = @"Dupe";
    }
    if (type) {
        launchParams = @{@"type" : type};
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(openLaunchURL:)
                                                     name:@"checkLaunchURL"
                                                   object:nil];
        completionHandler(YES);
        
    } else {
        completionHandler(NO);
    }
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler
{
    if (userActivity.userInfo[@"drinkContext"]) {
        context = [NSKeyedUnarchiver unarchiveObjectWithData:[userActivity.userInfo objectForKey:@"drinkContext"]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeActivity:)
                                                     name:@"checkForActivity"
                                                   object:nil];
        
        return YES;
    }
    
    return NO;
}

- (void)updateNotifications
{
    if ([[UserPreferences sharedInstance] allowsNotifications]) {
        DrinkingSession *session = [[StoredDataManager sharedInstance] currentSession];
        if (session) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
            [content setTitle:@"Session ended"];
            [content setSubtitle:@"B.A.C. has reached 0.00"];
            [content setBody:@"Are you ready to save the data to Health?"];
            [content setCategoryIdentifier:sessionEndedNotificationCategory];
            [content setUserInfo:@{kSessionFileName : session.fileName}];
            NSTimeInterval fireInterval = [session.projectedEndTime timeIntervalSinceNow];
            UNNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:fireInterval
                                                                                                repeats:NO];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:sessionEndedNotificationCategory
                                                                                  content:content
                                                                                  trigger:trigger];
            [center addNotificationRequest:request
                     withCompletionHandler:^(NSError * _Nullable error) {
                         if (error) {
                             NSLog(@"Error scheduleing end reminder");
                         }
                     }];
            if ([[UserPreferences sharedInstance] requestsReminders]) {
                NSTimeInterval interval = [[UserPreferences sharedInstance] updateInterval];
                if (interval > fireInterval + 60) {
                    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                    [content setTitle:@"Still Drinking?"];
                    [content setBody:@"Don't forget to add any drinks you've had to stay up to date."];
                    [content setCategoryIdentifier:drinkReminderNotificationCategory];
                    NSTimeInterval fireInterval = [[[session.drinks.lastObject date] dateByAddingTimeInterval:interval] timeIntervalSinceNow];
                    UNNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:fireInterval
                                                                                                        repeats:NO];
                    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:drinkReminderNotificationCategory
                                                                                          content:content
                                                                                          trigger:trigger];
                    [center addNotificationRequest:request
                             withCompletionHandler:^(NSError * _Nullable error) {
                                 if (error) {
                                     NSLog(@"Error scheduleing remidner notification");
                                 }
                             }];
                }
            }
        } else {
            [[UNUserNotificationCenter currentNotificationCenter] removeAllPendingNotificationRequests];
        }
        
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(UNNotificationPresentationOptionAlert);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler
{
    NSString *category = response.notification.request.content.categoryIdentifier;
    if ([category isEqualToString:sessionEndedNotificationCategory]) {
        if (![response.actionIdentifier isEqualToString:UNNotificationDismissActionIdentifier] && ![response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
            if ([response.actionIdentifier isEqualToString:saveActionIdentifier]) {
                [[HealthKitManager sharedInstance] saveSessions];
            } else if ([response.actionIdentifier isEqualToString:showDetailsActionIdentifier]) {
                NSLog(@"stop");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"showDetails"
                                                                    object:response.notification.request.content];
            }
        }
    } else if ([category isEqualToString:drinkReminderNotificationCategory]) {
        
    }
}

- (BOOL)watchAppNeedsSync {
    if (![[UserPreferences sharedInstance] hasSyncedWatchApp] && [[WCSession defaultSession] isWatchAppInstalled] && ![[StoredDataManager sharedInstance] needsSetup]) {
        return true;
    } else if ([[UserPreferences sharedInstance] hasSyncedWatchApp] && ![[WCSession defaultSession] isWatchAppInstalled]) {
        [[UserPreferences sharedInstance] setHasSyncedWatchApp:NO];
    }
    return false;
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
    launchParams = nil;
}

- (void)resumeActivity:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"checkForActivity"
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resumeActivity"
                                                        object:nil
                                                      userInfo:@{@"context" : context}];
    context = nil;
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

- (void)defineCategories{
    
    UNNotificationAction *showDetails = [UNNotificationAction actionWithIdentifier:showDetailsActionIdentifier
                                                                             title:@"Show Details"
                                                                           options:UNNotificationActionOptionForeground];
    UNNotificationAction *save = [UNNotificationAction actionWithIdentifier:saveActionIdentifier
                                                                      title:@"Save to Health"
                                                                    options:UNNotificationActionOptionNone];
    UNNotificationCategory *details = [UNNotificationCategory categoryWithIdentifier:sessionEndedNotificationCategory
                                                                             actions:@[showDetails, save]
                                                                      minimalActions:@[showDetails, save]
                                                                   intentIdentifiers:@[]
                                                                             options:UNNotificationCategoryOptionNone];
    UNNotificationAction *addDrink = [UNNotificationAction actionWithIdentifier:addDrinkActionIdentifier
                                                                          title:@"Add Drink"
                                                                        options:UNNotificationActionOptionForeground];
    UNNotificationCategory *add = [UNNotificationCategory categoryWithIdentifier:drinkReminderNotificationCategory
                                                                         actions:@[addDrink]
                                                                  minimalActions:@[addDrink]
                                                               intentIdentifiers:@[]
                                                                         options:UNNotificationCategoryOptionNone];
    [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObjects:details, add, nil]];
}

-(void)registerNotifications{
    UIAlertController *allowNotifications = [UIAlertController alertControllerWithTitle:@"Allow Notifications"
                                                                                message:@"Drink Keeper would like to send you notifications to let you know when your BAC has fallen below a certain level. Would you like to allow this?"
                                                                         preferredStyle:UIAlertControllerStyleAlert];
    [allowNotifications addAction:[UIAlertAction actionWithTitle:@"Don't Allow"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]];
    [allowNotifications addAction:[UIAlertAction actionWithTitle:@"Allow"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionBadge +  UNAuthorizationOptionSound)
                                                                                                                                 completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                                                                                                                     [[UserPreferences sharedInstance] setAllowsNotifcation:granted];
                                                                                                                                 }];
                                                            }]];
    [[(UINavigationController *)[self.window rootViewController] topViewController] presentViewController:allowNotifications
                       animated:YES
                     completion:nil];
    
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
    
    
    [[iOSWatchConnectionManager sharedInstance] appDidLaunch];

    [[HealthKitManager sharedInstance] updateHealthValues];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
