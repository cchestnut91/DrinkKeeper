//
//  DrinkingSession.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/22/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drink.h"
#import "BACTimelineItem.h"

@interface DrinkingSession : NSObject <NSCoding>

@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, strong) NSDate *endTime;
@property (strong, nonatomic) NSDate *projectedEndTime;
@property (strong, nonatomic) NSString *fileName;
@property (strong, nonatomic) NSNumber *bac;
@property (strong, nonatomic) NSArray *drinks;
@property (strong, nonatomic) NSMutableArray *timeline;
@property (strong, nonatomic) NSNumber *peak;
@property (strong, nonatomic) NSNumber *hangoverRating;
@property BOOL hasSavedToHealth;

-(void)addDrinkToSession:(Drink *)drinkIn;
-(void)removeLastDrink;
-(double)getCurrentBAC;
-(void)updateHangover:(NSNumber *)ratingIn;
-(void)updateBACTimeline;
-(NSNumber *)totalDrinks;
-(NSNumber *)numDrinks;
-(NSNumber *)numBeers;
-(NSNumber *)numWine;
-(NSNumber *)peakValue;
-(NSNumber *)hangoverRating;
-(NSString *)hangoverRatingStringValue;

-(BOOL)needsSaveToHealth;

- (BACTimelineItem *)getCurrentTimelineEntry;
- (NSArray *)getTimelineItemsBeforeDate:(NSDate *)date withLimit:(NSUInteger)limit;
- (NSArray *)getTimelineItemsAfterDate:(NSDate *)date withLimit:(NSUInteger)limit;

-(id)initWithCoder:(NSCoder *)aDecoder;
-(void)encodeWithCoder:(NSCoder *)aCoder;

@end
