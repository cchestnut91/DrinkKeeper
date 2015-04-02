//
//  HealthKitManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "HealthKitManager.h"
#import "StoredDataManager.h"

@implementation HealthKitManager

static HealthKitManager *sharedObject;

+(HealthKitManager *) sharedInstance{
    if (sharedObject == nil){
        sharedObject = [[HealthKitManager alloc] init];
    }
    
    return sharedObject;
}

-(id)init{
    self = [super init];
    
    self.weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    self.sexType = [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    self.bacType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    
    self.readTypes = [NSSet setWithObjects:self.weightType, self.sexType, nil];
    self.writeTypes = [NSSet setWithObject:self.bacType];
    
    self.healthStore = [[HKHealthStore alloc] init];
    
    self.sortRecentFirst = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate
                                                       ascending:NO];
    self.hasAskedPerission = [_healthStore authorizationStatusForType:_bacType] != HKAuthorizationStatusNotDetermined;
    
    return self;
}

-(void)saveBacWithValue:(double)bacValue{
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    HKQuantitySample *bacSample = [HKQuantitySample quantitySampleWithType:type
                                                                  quantity:[HKQuantity quantityWithUnit:[HKUnit percentUnit]
                                                                                            doubleValue:bacValue]
                                                                 startDate:[NSDate date]
                                                                   endDate:[NSDate date]];
    [self storeSample:bacSample
         withCallback:nil];
}

+(NSString *)stringForSex{
    HKBiologicalSex sex = [[[HealthKitManager sharedInstance] performSexQuery] biologicalSex];
    if (sex == HKBiologicalSexFemale){
        return @"Female";
    } else if (sex == HKBiologicalSexMale){
        return @"Male";
    } else {
        return @"Other";
    }
}

-(void)storeSample:(HKSample *)sampleIn withCallback:(void (^)(BOOL success, NSError *error))callback{
    if (self.hasAskedPerission){
        [self.healthStore saveObject:sampleIn
                      withCompletion:callback];
    }
}

-(void)updateHealthValues{
    if (self.hasAskedPerission){
        [self performWeightQueryWithCallback:^(HKSampleQuery *query, NSArray *results, NSError *error){
            double newWeight = 0.0;
            if (!error && results.count > 0 && [[[results lastObject] quantity] doubleValueForUnit:[HKUnit poundUnit]] != 0){
                newWeight = [[[results lastObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                if (newWeight != [[[StoredDataManager sharedInstance] getWeight] doubleValue]){
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:newWeight]
                                                                            forKey:[StoredDataManager weightKey]];
                }
            }
            HKBiologicalSex sex = [[self performSexQuery] biologicalSex];
            if (sex != [[[StoredDataManager sharedInstance] getSex] integerValue]){
                if (sex != HKBiologicalSexNotSet){
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex]
                                                                            forKey:[StoredDataManager sexKey]];
                }
            }
            
            [self saveBacWithValue:[[StoredDataManager sharedInstance] getCurrentBAC]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"healthValuesUpdated"
                                                                object:nil];
        }];
    }
}

-(void)performHealthKitRequestWithCallback:(void (^)(BOOL success, NSError *error))callback{
    if ((!self.hasAskedPerission && [[StoredDataManager sharedInstance] userHasRequestedHealth]) || ![self shouldRequestAccess]){
        if (self.healthStore){
            [self.healthStore requestAuthorizationToShareTypes:self.writeTypes
                                                     readTypes:self.readTypes
                                                    completion:callback];
            self.hasAskedPerission = YES;
        }
    }
}

-(void)performWeightQueryWithCallback:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))callback{
    
    HKSampleQuery *weightQuery = [[HKSampleQuery alloc] initWithSampleType:self.weightType
                                                                 predicate:nil
                                                                     limit:1
                                                           sortDescriptors:@[self.sortRecentFirst]
                                                            resultsHandler:callback];
    
    if (self.hasAskedPerission){
        [self.healthStore executeQuery:weightQuery];
    } else {
        if ([[StoredDataManager sharedInstance] userHasRequestedHealth]){
            [self performHealthKitRequestWithCallback:^(BOOL success, NSError *error){
                [self performWeightQueryWithCallback:callback];
                [self updateHealthValues];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"healthValuesUpdated"
                                                                    object:nil];
            }];
        }
    }
    
}

-(HKBiologicalSexObject *)performSexQuery{
    
    if ([self shouldRequestAccess]){
        [self performHealthKitRequestWithCallback:^(BOOL success, NSError *error){
            [self updateHealthValues];
        }];
        return nil;
    }
    NSError *error = nil;
    HKBiologicalSexObject *sex = [self.healthStore biologicalSexWithError:&error];
    if (error == nil){
        return sex;
    } else {
        return nil;
    }
}

+(NSInteger)sexForNumber:(NSInteger)number{
    if (!number){
        return 0;
    }
    if (number == HKBiologicalSexFemale){
        return HKBiologicalSexFemale;
    }
    if (number == HKBiologicalSexMale){
        return HKBiologicalSexMale;
    }
    return HKBiologicalSexNotSet;
}

-(BOOL)isHealthAvailable{
    return [HKHealthStore isHealthDataAvailable];
}

-(BOOL)shouldRequestAccess{
    if (!self.hasAskedPerission && [[StoredDataManager sharedInstance] userHasRequestedHealth]){
        return YES;
    }
    return NO;
}

@end
