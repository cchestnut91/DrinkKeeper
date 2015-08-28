//
//  BACTimelineItem.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 8/27/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BACTimelineItem : NSObject <NSCoding>

- (__nonnull instancetype) initWithBAC:(__nonnull NSNumber *)bacIn andDate:(__nonnull NSDate *)date;

- (__nonnull instancetype) initWithCoder:(__nonnull NSCoder *)aDecoder;
- (void)encodeWithCoder:(__nonnull NSCoder *)aCoder;

@property (strong, nonatomic) __nonnull NSNumber *bac;
@property (strong, nonatomic) __nonnull NSDate *date;

@end
