//
//  StoredDataManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "StoredDataManager.h"

NSString *weightKey = @"weight";
NSString *sexKey = @"sex";
NSString *sessionDir;

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
        sharedObject = [[super allocWithZone:NULL] init];
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

-(DrinkingSession *)getSessionForID:(NSString *)sessionID{
    
    DrinkingSession *ret = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionID]];
    
    return ret;
}

-(void)duplicateLastDrink{
    Drink *last = [[[self currentSession] drinks] lastObject];
    [last setTime:[NSDate date]];
    [self addDrinkToCurrentSession:last];
}

-(DrinkingSession *)currentSession{
    NSError *error = nil;
    NSArray *sessionFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sessionDirectory
                                                                                error:&error];
    
    for (NSString *sessionFile in sessionFiles){
        DrinkingSession *session = (DrinkingSession *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.sessionDirectory stringByAppendingPathComponent:sessionFile]];
        if ([session getUpdatedBAC] == 0.0){
            continue;
        }
        if ([[session drinks] count] > 0){
            [NSKeyedArchiver archiveRootObject:session
                                        toFile:[self.sessionDirectory stringByAppendingPathComponent:[session fileName]]];
            return session;
        }
    }
    return nil;
}

- (NSString *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"] path];
}

-(void)updateDictionaryWithObject:(id)objectIn forKey:(NSString *)keyIn{
    NSMutableDictionary *healthDic = [NSMutableDictionary dictionaryWithDictionary:self.healthDictionary];
    if (!healthDic){
        healthDic = [[NSMutableDictionary alloc] init];
    }
    [healthDic setObject:objectIn
                  forKey:keyIn];
    [NSKeyedArchiver archiveRootObject:healthDic
                                toFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]];
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

-(void)addDrinkToCurrentSession:(Drink *)drinkIn{
    DrinkingSession *session = [self currentSession];
    if (!session){
        session = [[DrinkingSession alloc] init];
    }
    [session addDrinkToSession:drinkIn];
    
    [NSKeyedArchiver archiveRootObject:session
                                toFile:[self.sessionDirectory stringByAppendingPathComponent:[session fileName]]];
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

-(NSDictionary *)healthDictionary{
    return (NSDictionary *)[NSKeyedUnarchiver unarchiveObjectWithFile:[self.applicationDocumentsDirectory stringByAppendingPathComponent:_healthData]];
}

-(double)getCurrentBAC{
    if ([self currentSession]){
// TODO Save Current Session?
        return [[self currentSession] getUpdatedBAC];
    }
    return 0.0;
}

@end
