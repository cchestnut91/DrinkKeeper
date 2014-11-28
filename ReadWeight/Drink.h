//
//  Drink.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddDrinkContext.h"

@interface Drink : NSObject <NSCoding>

@property (strong, nonatomic) NSDate *time;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSNumber *multiplier;

-(id)initWithDrinkContext:(AddDrinkContext *)context;
-(id)initWithType:(NSString *)typeIn andMultiplier:(NSNumber *)multIn andTime:(NSDate *)timeIn;
-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end
