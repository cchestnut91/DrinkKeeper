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
        if ([type isEqualToString:[AddDrinkContext beerType]]){
            
            [self setTitle:@"Add Beer"];
            
            [self setType:@"Beer"];
            
            NSArray *options = @[@1, @1.333, @1.666];
            NSArray *optionLabels = @[@"12 oz.", @"16 oz.", @"20 oz."];
            
            [self setStrengthOptions:options];
            [self setOptionLabels:optionLabels];
            self.selectedMult = [self.strengthOptions firstObject];

        } else if ([type isEqualToString:[AddDrinkContext wineType]]){
            
            [self setTitle:@"Add Wine"];
            
            [self setType:@"Wine"];
            
            NSArray *options = @[@0.75, @1, @1.25];
            NSArray *optionLabels = @[@"Small", @"Normal", @"Large"];
            
            [self setStrengthOptions:options];
            [self setOptionLabels:optionLabels];
            self.selectedMult = [self.strengthOptions objectAtIndex:1];
            
        } else if ([type isEqualToString:[AddDrinkContext liquorType]]){
            
            [self setTitle:@"Add Drink"];
            
            [self setType:@"Liquor"];
            
            NSArray *options = @[@0.75, @1, @1.5, @2];
            NSArray *optionLabels = @[@"Weak", @"Normal", @"Strong", @"Woah!"];
            
            [self setStrengthOptions:options];
            [self setOptionLabels:optionLabels];
            self.selectedMult = [self.strengthOptions objectAtIndex:1];
            
        }
        
        if (self.strengthOptions){
        }
        
        self.time = [NSDate date];
    }
    
    return self;
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
