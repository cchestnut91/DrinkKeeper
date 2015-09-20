//
//  AddDrinkContext.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AddDrinkContext.h"

@implementation AddDrinkContext

-(id)initWithType:(NSString *)type{
    self = [super init];
    if (self){
        if ([[type lowercaseString] isEqualToString:[AddDrinkContext beerType]]){
            
            [self setTitle:@"Beer"];
            
            [self setType:@"Beer"];
            
            NSArray *options = @[@1, @1.333, @1.666];
            NSArray *optionLabelsImp = @[@"12 oz.", @"16 oz.", @"20 oz."];
            NSArray *optionsMetric = @[@"350 ml", @"470 ml", @"590 ml"];
            
            [self setStrengthOptions:options];
            [self setOptionLabels:optionLabelsImp];
            [self setMetricLabels:optionsMetric];
            
            self.selectedIndex = 0;

        } else if ([[type lowercaseString] isEqualToString:[AddDrinkContext wineType]]){
            
            [self setTitle:@"Wine"];
            
            [self setType:@"Wine"];
            
            NSArray *options = @[@0.75, @1, @1.25];
            NSArray *optionLabelsImp = @[@"Small (< 5 oz.)", @"Normal (5-6 oz.)", @"Large (> 6 oz.)"];
            NSArray *optionsMetric = @[@"Small (< 150 ml)", @"Normal (150-175 ml)", @"Large (> 175 ml)"];
            
            [self setStrengthOptions:options];
            [self setOptionLabels:optionLabelsImp];
            [self setMetricLabels:optionsMetric];
            
            self.selectedIndex = 1;
            
        } else if ([[type lowercaseString] isEqualToString:[AddDrinkContext liquorType]]){
            
            [self setTitle:@"Drink"];
            
            [self setType:@"Liquor"];
            
            NSArray *options = @[@0.75, @1, @1.5, @2];
            NSArray *optionLabelsImp = @[@"Weak (< 1 oz.)", @"Normal (1.5 oz.)", @"Strong (2-3 oz.)", @"Woah! (> 3 oz.)"];
            NSArray *optionsMetric = @[@"Weak (< 30 ml)", @"Normal (45 ml)", @"Strong (60-90 ml)", @"Woah! (> 90 ml)"];
            
            [self setStrengthOptions:options];
            [self setOptionLabels:optionLabelsImp];
            [self setMetricLabels:optionsMetric];
            
            self.selectedIndex = 1;
        }
        self.selectedMult = [self.strengthOptions objectAtIndex:self.selectedIndex];
        
        if (self.strengthOptions){
        }
        
        self.time = [NSDate date];
    }
    
    return self;
}

-(NSString *)titleForMult:(BOOL)metric{
    NSString *ret;
    NSArray *options = metric ? self.metricLabels : self.optionLabels;
    
    for (NSNumber *num in self.strengthOptions){
        if (self.selectedMult == num){
            ret = [options objectAtIndex:[self.strengthOptions indexOfObject:num]];
            self.selectedIndex = [self.strengthOptions indexOfObject:num];
        }
    }
    
    return ret;
}

+(NSString *)beerType{
    return @"beer";
}
+(NSString *)wineType;{
    return @"wine";
}
+(NSString *)liquorType{
    return @"liquor";
}

@end
