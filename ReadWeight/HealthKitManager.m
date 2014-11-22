//
//  HealthKitManager.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "HealthKitManager.h"

@implementation HealthKitManager

static HealthKitManager *sharedObject;

+(HealthKitManager *) sharedInstance{
    if (sharedObject == nil){
        sharedObject = [[super allocWithZone:NULL] init];
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
    
    self.sortRecentFirst = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    return self;
}

-(void)performHealthKitRequestWithCallback:(void (^)(BOOL success, NSError *error))callback{
    if (self.healthStore){
        [self.healthStore requestAuthorizationToShareTypes:self.writeTypes
                                                 readTypes:self.readTypes
                                                completion:callback];
    }
}

-(void)performWeightQueryWithCallback:(void (^)(HKSampleQuery *query, NSArray *results, NSError *error))callback{
    
    HKSampleQuery *weightQuery = [[HKSampleQuery alloc] initWithSampleType:self.weightType
                                                                 predicate:nil
                                                                     limit:1
                                                           sortDescriptors:@[self.sortRecentFirst]
                                                            resultsHandler:callback];
    [self.healthStore executeQuery:weightQuery];
    
}

-(HKBiologicalSexObject *)performSexQuery{
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
@end
