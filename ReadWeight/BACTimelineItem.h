//
//  BACTimelineItem.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 8/27/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BACTimelineItem : NSObject <NSCoding>

- (__nonnull instancetype) initWithBAC:(NSNumber * _Nonnull )bacIn andDate:(NSDate * _Nonnull )date andNumDrinks:(NSNumber * _Nonnull )drinks;

- (_Nonnull instancetype) initWithCoder:(NSCoder * _Nonnull)aDecoder;
- (void)encodeWithCoder:(NSCoder *_Nonnull)aCoder;

@property (strong, nonatomic)  NSNumber * _Nonnull bac;
@property (strong, nonatomic) NSDate * _Nonnull date;
@property (strong, nonatomic) NSNumber * _Nonnull numberOfDrinks;

@end
