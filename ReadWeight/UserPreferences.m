//
//  UserPreferences.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/12/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "UserPreferences.h"

#import "StoredDataManager.h"

@interface UserPreferences ()

@property NSString *prefDirectory;
@property NSString *prefFile;

@end

@implementation UserPreferences

static UserPreferences *sharedObject;

- (instancetype)initPrivate {
    self = [super init];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *container = [manager containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"];
    self.prefDirectory = [[container path] stringByAppendingPathComponent:@"userPreferences"];
    self.prefFile = [self.prefDirectory stringByAppendingPathComponent:@"prefs.plist"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.prefDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.prefDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
        NSDictionary *preferences = @{@"prefersMetric" : @0,
                                      @"dateCreated" : [NSDate date],
                                      @"hasShownShakeInfo" : [NSNumber numberWithBool:[[[[StoredDataManager sharedInstance] healthDictionary] objectForKey:@"hasShownShakeInfo"] boolValue]],
                                      @"watchAppSynced" : @0,
                                      @"allowNotifications" : @0,
                                      @"updateInterval" : @0};
        
        [NSKeyedArchiver archiveRootObject:preferences toFile:self.prefFile];
        [[StoredDataManager sharedInstance] updateUserPreferenceContext];
    }
    
    return self;
}

+(instancetype) sharedInstance{
    if (sharedObject == nil){
        sharedObject = [[UserPreferences alloc] initPrivate];
    }
    
    return sharedObject;
}

- (void)updateWithContext:(NSDictionary *)dictionary {
    [NSKeyedArchiver archiveRootObject:dictionary toFile:self.prefFile];
}

- (BOOL)prefersMetric {
    NSDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile];
    return [[prefs objectForKey:@"prefersMetric"] boolValue];
}

- (void)setPrefersMetric:(BOOL)prefersMetric {
    NSMutableDictionary *mutable = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile] mutableCopy];
    [mutable setObject:[NSNumber numberWithBool:prefersMetric] forKey:@"prefersMetric"];
    
    [NSKeyedArchiver archiveRootObject:mutable toFile:self.prefFile];
    [[StoredDataManager sharedInstance] updateUserPreferenceContext];
}

- (BOOL)allowsNotifications
{
    NSDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile];
    return [[prefs objectForKey:@"allowNotifications"] boolValue];
}

- (void)setAllowsNotifcation:(BOOL)allowsNotifcation
{
    NSMutableDictionary *mutable = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile] mutableCopy];
    [mutable setObject:[NSNumber numberWithBool:allowsNotifcation] forKey:@"allowNotifications"];
    
    [NSKeyedArchiver archiveRootObject:mutable toFile:self.prefFile];
    [[StoredDataManager sharedInstance] updateUserPreferenceContext];
}

- (BOOL)hasShownShakeInfo {
    NSDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile];
    return [[prefs objectForKey:@"hasShownShakeInfo"] boolValue];
}

- (void)setHasShownShakeInfo:(BOOL)shakeShown {
    NSMutableDictionary *mutable = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile] mutableCopy];
    [mutable setObject:[NSNumber numberWithBool:shakeShown] forKey:@"hasShownShakeInfo"];
    
    [NSKeyedArchiver archiveRootObject:mutable toFile:self.prefFile];
    [[StoredDataManager sharedInstance] updateUserPreferenceContext];
}

- (BOOL)hasSyncedWatchApp {
    NSDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile];
    return [[prefs objectForKey:@"watchAppSynced"] boolValue];
}

- (void)setHasSyncedWatchApp:(BOOL)watchSynced {
    NSMutableDictionary *mutable = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile] mutableCopy];
    [mutable setObject:[NSNumber numberWithBool:watchSynced] forKey:@"watchAppSynced"];
    
    [NSKeyedArchiver archiveRootObject:mutable toFile:self.prefFile];
    [[StoredDataManager sharedInstance] updateUserPreferenceContext];
}

- (BOOL)requestsReminders
{
    return [self updateInterval] != 0;
}

- (NSTimeInterval)updateInterval
{
    NSDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile];
    return [[prefs objectForKey:@"updateInterval"] integerValue];
}

- (void)setUpdateInterval:(NSTimeInterval)updateInterval
{
    NSMutableDictionary *mutable = [[NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile] mutableCopy];
    [mutable setObject:[NSNumber numberWithInteger:updateInterval] forKey:@"updateInterval"];
    
    [NSKeyedArchiver archiveRootObject:mutable toFile:self.prefFile];
    [[StoredDataManager sharedInstance] updateUserPreferenceContext];
}

- (NSDate *)verTwoUpdated {
    NSDictionary *prefs = [NSKeyedUnarchiver unarchiveObjectWithFile:self.prefFile];
    return [prefs objectForKey:@"dateCreated"];
}

@end
