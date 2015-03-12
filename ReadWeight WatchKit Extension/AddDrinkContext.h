//
//  AddDrinkContext.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddDrinkContext : NSObject

@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSArray *strengthOptions;
@property (strong, nonatomic) NSArray *optionLabels;
@property (strong, nonatomic) NSDate *time;
@property (strong, nonatomic) NSNumber *selectedMult;
+(NSString *)beerType;
+(NSString *)wineType;
+(NSString *)liquorType;

-(id)initWithType:(NSString *)type;


@end
