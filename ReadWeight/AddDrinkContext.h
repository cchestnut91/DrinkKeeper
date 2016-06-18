//
//  AddDrinkContext.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddDrinkContext : NSObject <NSCoding>

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) NSDate *time;

@property (strong, nonatomic) NSMeasurement *standardSize;
@property (strong, nonatomic) NSMeasurement *size;
@property double standardContent;
@property double content;

@property (strong, nonatomic) NSArray<NSMeasurement *> *suggestions;

- (NSNumber *)getMult;

+(NSString *)beerType;
+(NSString *)wineType;
+(NSString *)liquorType;

-(NSArray *)getSuggestionsInMetric:(BOOL)metric;

-(NSString *)titleForStandard:(BOOL)metric;

-(NSString *)titleForSize:(BOOL)metric;

-(NSArray *)suggestionStrings:(BOOL)metric;

-(NSArray *)suggestionStringsDefaultOnly:(BOOL)metric;

-(id)initWithType:(NSString *)type;

- (instancetype)initWithCoder:(NSCoder *)aDecoder;
- (void)encodeWithCoder:(NSCoder *)aCoder;

@end
