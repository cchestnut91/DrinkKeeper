//
//  StoredDataManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "StoredDataManager.h"

@interface StoredDataManager()

@property (strong, nonatomic) NSString *savedSessionsFile;

@end

NSString *weightKey = @"weight";
NSString *sexKey = @"sex";
NSString *sessionDir;
DrinkingSession *forceSession;

@implementation StoredDataManager

static StoredDataManager *sharedObject;

+(NSString *)weightKey{
    return weightKey;
}

+(NSString *)sexKey{
    return sexKey;
}

+(StoredDataManager *) sharedInstance{
    if (sharedObject == nil){
        sharedObject = [[super alloc] init];
    }
    
    return sharedObject;
}

-(id)init{
    self = [super init];
    
    self.healthData = @"healthData";
    self.sessionDirectory = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"drinkingSessions"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.sessionDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:self.sessionDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    
    self.savedSessions = [[NSMutableDictionary alloc] init];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *container = [manager containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"];
    self.savedSessionsFile = [[container path] stringByAppendingPathComponent:@"savedSessions"];
    
    if (![manager fileExistsAtPath:self.savedSessionsFile]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.savedSessionsFile withIntermediateDirectories:NO attributes:nil error:nil];
    } else {
        NSMutableDictionary *mutableSessions = [NSMutableDictionary new];
        NSError *error;
        NSArray *sessionFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.savedSessionsFile
                                                                                    error:&error];
        
        for (NSString *sessionFile in sessionFiles){
            
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedUnarchiver unarchiveObjectWithFile:[self.savedSessionsFile stringByAppendingPathComponent:sessionFile]]];
            [mutableSessions setObject:array forKey:sessionFile];
        }
        self.savedSessions = mutableSessions;
    }
    
    return self;
}

-(DrinkingSession *)lastSession{
    DrinkingSession *ret = [self currentSession];
    if (ret == nil){
        DrinkingSession *mostRecent;
        NSError *error = nil;
        NSArray *sessionFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sessionDirectory
                                                                                    error:&error];
        
        for (NSString *sessionFile in sessionFiles){
            DrinkingSession *session = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionFile]];
            if (!mostRecent){
                mostRecent = session;
            } else {
                if ([[session startTime] compare:[mostRecent startTime]] == NSOrderedDescending){
                    mostRecent = session;
                }
            }
        }
        
        if (mostRecent){
            return mostRecent;
        }
    }
    return ret;
}

-(void)saveDrinkingSession:(DrinkingSession *)session{
	
	[NSKeyedArchiver archiveRootObject:session
								toFile:[self.sessionDirectory stringByAppendingPathComponent:[session fileName]]];

}

- (void)markSessionSaved:(DrinkingSession *)session withValues:(NSArray *)values {
    [self.savedSessions setObject:values forKey:session.fileName];
    
    for (NSString *key in self.savedSessions.allKeys) {
        
        [NSKeyedArchiver archiveRootObject:[NSKeyedArchiver archivedDataWithRootObject:self.savedSessions[key]] toFile:[self.savedSessionsFile stringByAppendingPathComponent:key]];
    }
    
    [self updateLastSessionContext];
}

-(void)removeDrinkingSession:(DrinkingSession *)session{
	
	[[NSFileManager defaultManager] removeItemAtPath:[self.sessionDirectory stringByAppendingPathComponent:[session fileName]] error:nil];
}

-(DrinkingSession *)getSessionForID:(NSString *)sessionID{
    
    DrinkingSession *ret = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionID]];
    
    return ret;
}

-(void)duplicateLastDrink{
    Drink *last = [[[self currentSession] drinks] lastObject];
    
    if (last) {
        [last setTime:[NSDate date]];
        [self addDrinkToCurrentSession:last];
    }
}

-(DrinkingSession *)currentSession{

    NSError *error = nil;
    
    NSArray *sessionFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sessionDirectory
                                                                                error:&error];
    
    for (NSString *sessionFile in sessionFiles){
        DrinkingSession *session = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionFile]];
        
        if ([[NSDate date] compare:[session projectedEndTime]] == NSOrderedAscending) {
            return session;
        }
    }
    return nil;
}

- (NSArray *)pastSessions {
    NSArray *ret = [NSArray new];
    
    NSError *error = nil;
    NSArray *sessionFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sessionDirectory
                                                                                error:&error];
    
    for (NSString *sessionFile in sessionFiles){
        DrinkingSession *session = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionFile]];
        if ([session.projectedEndTime compare:[NSDate date]] == NSOrderedAscending && session.timeline != nil) {
            ret = [ret arrayByAddingObject:session];
        }
    }
    
    ret = [ret sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        DrinkingSession *a = (DrinkingSession *)obj1;
        DrinkingSession *b = (DrinkingSession *)obj2;
        
        return [b.projectedEndTime compare:a.projectedEndTime];
    }];
    
    return ret;
}

- (NSArray *)sessionsToSave
{
    NSMutableArray *ret = [NSMutableArray new];
    
    for (DrinkingSession *session in [self pastSessions]) {
        if (session.needsSaveToHealth) {
            [ret addObject:session];
        }
    }
    
    return ret;
}

- (NSString *)applicationDocumentsDirectory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *container = [manager containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"];
    NSString *ret = [container path];
    return ret;
}

// This block gives a static demo session for screenshots and demos
/*
 if (!forceSession){
 AddDrinkContext *newContext = [[AddDrinkContext alloc] initWithType:@"Beer"];
 [newContext setTime:[NSDate dateWithTimeIntervalSinceNow:-4320]];
 Drink *toAdd = [[Drink alloc] initWithDrinkContext:newContext];
 forceSession = [[DrinkingSession alloc] init];
 [forceSession addDrinkToSession:toAdd];
 
 newContext = [[AddDrinkContext alloc] initWithType:@"Beer"];
 [newContext setTime:[NSDate dateWithTimeIntervalSinceNow:-1000]];
 toAdd = [[Drink alloc] initWithDrinkContext:newContext];
 [forceSession addDrinkToSession:toAdd];
 
 [forceSession setPeak:@0.00026];
 }
 
 return forceSession;
 
 if (!forceSession){
 forceSession = [[DrinkingSession alloc] init];
 AddDrinkContext *newContext = [[AddDrinkContext alloc] initWithType:@"Beer"];
 [newContext setTime:[NSDate dateWithTimeIntervalSinceNow:-1740]];
 Drink *newDrink = [[Drink alloc] initWithDrinkContext:newContext];
 [forceSession addDrinkToSession:newDrink];
 
 [forceSession setPeak:@0.00022];
 }
 
 return forceSession;
 
 */

-(void)updateDictionaryWithObject:(id)objectIn forKey:(NSString *)keyIn{
    NSMutableDictionary *healthDic = [NSMutableDictionary dictionaryWithDictionary:self.healthDictionary];
    if (!healthDic){
        healthDic = [[NSMutableDictionary alloc] init];
    }
    [healthDic setObject:objectIn
                  forKey:keyIn];
    [NSKeyedArchiver archiveRootObject:healthDic
                                toFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]];
    [self updateHealthDictionaryContext];
    
}

-(void)setWeight:(id)weightIn{
    [self updateDictionaryWithObject:weightIn
                              forKey:weightKey];
}

-(void)setSex:(id)sexIn{
    [self updateDictionaryWithObject:sexIn
                              forKey:sexKey];
}

-(id)getWeight{
    if ([self healthDictionary]){
        return [[self healthDictionary] objectForKey:weightKey];
    }
    return nil;
}

-(id)getSex{
    if ([self healthDictionary]){
        return [[self healthDictionary] objectForKey:sexKey];
    }
    return nil;
}

-(void)addDrinkToCurrentSession:(Drink *)drinkIn {
    DrinkingSession *session = [self currentSession];
    if (!session){
        NSError *error;
        NSArray *sessionFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sessionDirectory
                                                                                    error:&error];
        
        for (NSString *sessionFile in sessionFiles){
            DrinkingSession *existingSession = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionFile]];
            if ([existingSession.projectedEndTime compare:drinkIn.time] == NSOrderedDescending) {
                session = existingSession;
                break;
            }
        }
        if (!session) {
            session = [[DrinkingSession alloc] init];
        }
    }
    [session addDrinkToSession:drinkIn];
}

-(void)removeLastDrink{
    DrinkingSession *session = [self lastSession];
    [session removeLastDrink];
}

-(double)metabolismConstant{
    NSInteger sex = [[[StoredDataManager sharedInstance] getSex] integerValue];
    if (sex == 2){
        return 0.015;
    } else if (sex == 1){
        return 0.017;
    } else {
        return 0.016;
    }
}

-(double)genderStandard{
    NSInteger sex = [[[StoredDataManager sharedInstance] getSex] integerValue];
    if (sex == 2){
        return 0.58;
    } else if (sex == 1){
        return 0.49;
    } else {
        return 0.535;
    }
}

-(BOOL)needsSetup{
    if ([self healthDictionary] == nil){
        return YES;
    }
    if ([self getWeight] == nil){
        return YES;
    }
    if ([self getSex] == nil){
        return YES;
    }
    return NO;
}

-(void)userRequestsHealth{
	[self updateDictionaryWithObject:@1 forKey:@"hasRequestedHealth"];
}

-(BOOL)userHasRequestedHealth{
	id hasRequestedHealth = [[self healthDictionary] objectForKey:@"hasRequestedHealth"];
	return hasRequestedHealth != nil;
}

-(NSDictionary *)healthDictionary{
    NSDictionary *ret = (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]];
    return ret;
}

-(double)getCurrentBAC{
    if ([self currentSession]){
        return [[self currentSession] getCurrentBAC];
    }
    return 0.0;
}

- (BACTimelineItem *)getCurrentTimelineEntry {
    return [self.lastSession getCurrentTimelineEntry];
}

- (NSArray *)getTimelineItemsBeforeDate:(NSDate *)date withLimit:(NSUInteger)limit {
    return [self.lastSession getTimelineItemsBeforeDate:date withLimit:limit];
}

- (NSArray *)getTimelineItemsAfterDate:(NSDate *)date withLimit:(NSUInteger)limit {
    return [self.lastSession getTimelineItemsAfterDate:date withLimit:limit];
}

- (void)updateWatchContext {
    if ([WCSession isSupported] && ![self needsSetup]) {
        [[UserPreferences sharedInstance] setHasSyncedWatchApp:YES];
        [[AppWatchConnectionManager sharedInstance] updateContext:[self watchContext]];
    }
}

- (void)updateUserPreferenceContext {
    if ([WCSession isSupported] && ![self needsSetup]) {
        [[AppWatchConnectionManager sharedInstance] updateContext:[self userPrefContext]];
    }
}

- (void)updateHealthDictionaryContext {
    if ([WCSession isSupported] && ![self needsSetup]) {
        [[AppWatchConnectionManager sharedInstance] updateContext:[self healthContext]];
    }
}

- (void)updateSavedSessionContextWithContext:(NSDictionary *)dict {
    if ([WCSession isSupported] && ![self needsSetup]) {
        [[AppWatchConnectionManager sharedInstance] updateContext:dict];
    }
}

- (void)updateLastSessionContext {
    if ([WCSession isSupported] && ![self needsSetup]) {
        [[AppWatchConnectionManager sharedInstance] updateContext:[self lastSessionContext]];
    }
}

- (NSDictionary *)watchContext {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableDictionary *sessions = [NSMutableDictionary new];
    
    DrinkingSession *session = [self lastSession];
    
    if (session) {
        [sessions setObject:[NSKeyedArchiver archivedDataWithRootObject:session] forKey:session.fileName];
    }
    
    [dict setObject:sessions forKey:@"sessions"];
    
    NSMutableDictionary *health = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]]];
    
    if (health) {
        [dict setObject:health forKey:@"healthDictionary"];
    }
    
    NSString *prefDirectory = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"userPreferences"];
    NSString *prefFile = [prefDirectory stringByAppendingPathComponent:@"prefs.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:prefFile]) {
        [dict setObject:[NSKeyedUnarchiver unarchiveObjectWithFile:prefFile] forKey:@"userPreferences"];
    }
    
    NSString *savedSessionsFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"savedSessions"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:savedSessionsFile]) {
        NSMutableDictionary *mutableSessions = [NSMutableDictionary new];
        NSString *sessionFile = [savedSessionsFile stringByAppendingPathComponent:session.fileName];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]) {
            NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedUnarchiver unarchiveObjectWithFile:sessionFile]];
            [mutableSessions setObject:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:session.fileName];
        }
        
        [dict setObject:mutableSessions forKey:@"savedSessions"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *)lastSessionContext {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableDictionary *sessions = [NSMutableDictionary new];
    
    DrinkingSession *session = [self lastSession];
    
    [sessions setObject:[NSKeyedArchiver archivedDataWithRootObject:session] forKey:session.fileName];
    
    [dict setObject:sessions forKey:@"sessions"];
    
    
    NSString *savedSessionsFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"savedSessions"];
    NSString *savedSessionArrayLoc = [savedSessionsFile stringByAppendingPathComponent:session.fileName];
    NSData *data = [NSKeyedUnarchiver unarchiveObjectWithFile:savedSessionArrayLoc];
    NSArray *savedValues = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [dict setObject:@{session.fileName : [NSKeyedArchiver archivedDataWithRootObject:savedValues]} forKey:@"savedSessions"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *)healthContext {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableDictionary *health = [NSMutableDictionary dictionaryWithDictionary:[NSKeyedUnarchiver unarchiveObjectWithFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]]];
    
    [dict setObject:health forKey:@"healthDictionary"];
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (NSDictionary *)userPrefContext {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSString *prefDirectory = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"userPreferences"];
    NSString *prefFile = [prefDirectory stringByAppendingPathComponent:@"prefs.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:prefFile]) {
        [dict setObject:[NSKeyedUnarchiver unarchiveObjectWithFile:prefFile] forKey:@"userPreferences"];
    }
    
    return [NSDictionary dictionaryWithDictionary:dict];
}

- (void)handleMessage:(NSDictionary *)message {
    if (message[@"healthDictionary"]) {
        [NSKeyedArchiver archiveRootObject:message[@"healthDictionary"]
                                    toFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]];
    }
    if (message[@"sessions"]) {
        NSArray *sessions = message[@"sessions"];
        
        for (DrinkingSession *session in sessions) {
            [NSKeyedArchiver archiveRootObject:session toFile:[self.sessionDirectory stringByAppendingPathComponent:[session fileName]]];
        }
    }
}

- (void)handleContext:(NSDictionary *)context {
    if (context[@"healthDictionary"]) {
        [NSKeyedArchiver archiveRootObject:context[@"healthDictionary"]
                                    toFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]];
    }
    if (context[@"sessions"]) {
        NSArray *sessions = [self sessionsFromDataArray:context[@"sessions"]];
        
        for (DrinkingSession *session in sessions) {
            [NSKeyedArchiver archiveRootObject:session toFile:[self.sessionDirectory stringByAppendingPathComponent:[session fileName]]];
        }
        
        [(AppWatchConnectionManager *)[[WCSession defaultSession] delegate] updateComplication];
    }
    if (context[@"userPreferences"]) {
        [[UserPreferences sharedInstance] updateWithContext:context[@"userPreferences"]];
    }
    if (context[@"savedSessions"]) {
        NSString *savedSessionsFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"savedSessions"];
        
        NSDictionary *dict = [context objectForKey:@"savedSessions"];
        
        for (NSString *key in dict.allKeys) {
            [NSKeyedArchiver archiveRootObject:[NSKeyedArchiver archivedDataWithRootObject:[dict valueForKey:key]] toFile:[savedSessionsFile stringByAppendingPathComponent:key]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"contextReloaded" object:nil];
}

- (NSArray *)sessionsFromDataArray:(NSDictionary *)sessions {
    NSArray *ret = [NSArray new];
    
    for (NSData *sessionData in [sessions allValues]) {
        DrinkingSession *session = [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
        
        ret = [ret arrayByAddingObject:session];
    }
    
    return ret;
}

@end
