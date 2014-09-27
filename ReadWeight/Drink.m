//
//  Drink.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "Drink.h"

@implementation Drink

-(id)initWithType:(NSString *)typeIn andMultiplier:(NSNumber *)multIn andTime:(NSDate *)timeIn{
    self = [super init];
    
    self.type = typeIn;
    self.time = timeIn;
    self.multiplier = multIn;
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    self.type = [aDecoder decodeObjectForKey:@"type"];
    self.time = [aDecoder decodeObjectForKey:@"time"];
    self.multiplier = [aDecoder decodeObjectForKey:@"mult"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.type forKey:@"type"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.multiplier forKey:@"mult"];
}

@end
