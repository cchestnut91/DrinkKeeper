//
//  HealthKitManager.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

#import "DrinkingSession.h"

@interface HealthKitManager : NSObject

@property (strong, nonatomic) HKHealthStore *healthStore;
@property NSSet *readTypes;
@property NSSet *writeTypes;
@property HKSampleType *weightType;
@property HKCharacteristicType *sexType;
@property HKSampleType *bacType;
@property NSSortDescriptor *sortRecentFirst;
@property BOOL hasAskedPerission;

+(HealthKitManager *)sharedInstance;

-(void)performHealthKitRequestWithCallback:(void (^)(BOOL success, NSError *error))callback;

-(void)performWeightQueryWithCallback:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))callback;

-(HKBiologicalSexObject *)performSexQuery;

+(NSInteger)sexForNumber:(NSInteger)number;

-(void)storeSample:(HKSample *)sampleIn withCallback:(void (^)(BOOL success, NSError *error))callback;

-(void)saveDrinkingSession:(DrinkingSession *)session withCallback:(void (^)(BOOL success, NSError *error))callback;

-(void)saveBacWithValue:(double)bacValue;

- (void)saveSessions;

-(void)updateHealthValues;

+(NSString *)stringForSex;

- (NSArray *)valuesForSession:(DrinkingSession *)session;

-(BOOL)isHealthAvailable;

@end