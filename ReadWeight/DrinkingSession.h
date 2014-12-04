//
//  DrinkingSession.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/22/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drink.h"

@interface DrinkingSession : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (strong, nonatomic) NSDate *projectedEndTime;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSNumber *bac;
@property (strong, nonatomic) NSArray *drinks;
@property (strong, nonatomic) NSNumber *peak;
@property (strong, nonatomic) NSNumber *hangoverRating;

-(void)addDrinkToSession:(Drink *)drinkIn;
-(double)getUpdatedBAC;
-(void)updateHangover:(NSNumber *)ratingIn;
-(void)updateBAC:(double)bacIn;
-(NSNumber *)totalDrinks;
-(NSNumber *)numDrinks;
-(NSNumber *)numBeers;
-(NSNumber *)numWine;
-(NSNumber *)peakValue;
-(NSNumber *)hangoverRating;
-(NSString *)hangoverRatingStringValue;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end
