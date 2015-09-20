//
//  BACTimelineItem.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 8/27/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "BACTimelineItem.h"

@implementation BACTimelineItem

- (instancetype) initWithBAC:(NSNumber *)bacIn andDate:(NSDate *)date andNumDrinks:(NSNumber * _Nonnull)drinks{
    self = [super init];
    
    self.bac = bacIn;
    self.date = date;
    self.numberOfDrinks = drinks;
    
    return self;
}

- (void) encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.bac forKey:@"bac"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeObject:self.numberOfDrinks forKey:@"numberOfDrinks"];
}

- (instancetype) initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    
    self.bac = [aDecoder decodeObjectForKey:@"bac"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    self.numberOfDrinks = [aDecoder decodeObjectForKey:@"numberOfDrinks"];
    
    return self;
}


@end
