//
//  BACTimelineItem.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 8/27/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "BACTimelineItem.h"

@implementation BACTimelineItem

- (instancetype) initWithBAC:(NSNumber *)bacIn andDate:(NSDate *)date {
    self = [super init];
    
    self.bac = bacIn;
    self.date = date;
    
    return self;
}

- (void) encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:self.bac forKey:@"bac"];
    [aCoder encodeObject:self.date forKey:@"date"];
}

- (instancetype) initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    
    self.bac = [aDecoder decodeObjectForKey:@"bac"];
    self.date = [aDecoder decodeObjectForKey:@"date"];
    
    return self;
}


@end
