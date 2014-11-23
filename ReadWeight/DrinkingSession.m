//
//  DrinkingSession.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/22/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "DrinkingSession.h"
#import "StoredDataManager.h"

@implementation DrinkingSession

-(double)getUpdatedBAC{
    double bac;
    double consumed = 0.0;
    for (Drink *drink in [self drinks]){
        double add = [[drink multiplier] doubleValue];
        consumed += add;
    }
    consumed = consumed * 0.806 * 1.2;
    double genderStandard = [[StoredDataManager sharedInstance] genderStandard];
    double kgweight =([[[StoredDataManager sharedInstance] getWeight] doubleValue] * 0.454);
    double weightMod = genderStandard * kgweight;
    double newBac = consumed / weightMod;
    double hoursDrinking = [[NSDate date] timeIntervalSinceDate:[self startTime]] / 60.0 / 60.0;
    double metabolized = [[StoredDataManager sharedInstance] metabolismConstant] * hoursDrinking;
    bac = newBac - metabolized;
    if (bac <= 0.0){
        bac = 0.0;
    }
    
    bac = bac / 100;
    
    [self updateBAC:bac];
    return bac;
}

-(void)updateBAC:(double)bacIn{
    self.bac = [NSNumber numberWithDouble:bacIn];
}

-(void)addDrinkToSession:(Drink *)drinkIn{
    if (!self.drinks){
        self.drinks = [[NSArray alloc] init];
    }
    self.drinks = [self.drinks arrayByAddingObject:drinkIn];
    if (!self.startTime){
        self.startTime = [NSDate date];
        self.fileName = [NSString stringWithFormat:@"%f", [self.startTime timeIntervalSince1970]];
    }
    [self getUpdatedBAC];
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
    self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
    self.bac = [aDecoder decodeObjectForKey:@"bac"];
    self.drinks = [aDecoder decodeObjectForKey:@"drinks"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.bac forKey:@"bac"];
    [aCoder encodeObject:self.drinks forKey:@"drinks"];
}

@end
