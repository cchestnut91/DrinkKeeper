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
    self.sessionDirectory = @"drinkingSessions";
    
    return self;
}

- (NSString *)applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
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

@end
