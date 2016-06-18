//
//  AddDrinkContext.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AddDrinkContext.h"

@implementation AddDrinkContext

-(id)initWithType:(NSString *)type{
    self = [super init];
    if (self){
        if ([[type lowercaseString] isEqualToString:[AddDrinkContext beerType]]){
            
            [self setTitle:@"Beer"];
            
            [self setType:@"Beer"];
            
            self.standardSize = [[NSMeasurement alloc] initWithDoubleValue:12.0
                                                                      unit:[NSUnitVolume fluidOunces]];
            self.standardContent = 0.05;
            
            self.suggestions = @[[[NSMeasurement alloc] initWithDoubleValue:12.0
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:16.0
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:20.0
                                                                       unit:[NSUnitVolume fluidOunces]]];
            
            

        } else if ([[type lowercaseString] isEqualToString:[AddDrinkContext wineType]]){
            
            [self setTitle:@"Wine"];
            
            [self setType:@"Wine"];
            
            self.standardSize = [[NSMeasurement alloc] initWithDoubleValue:5.0
                                                                      unit:[NSUnitVolume fluidOunces]];
            self.standardContent = 0.125;
            
            self.suggestions = @[[[NSMeasurement alloc] initWithDoubleValue:4.0
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:5.5
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:7.0
                                                                       unit:[NSUnitVolume fluidOunces]]];
            
        } else if ([[type lowercaseString] isEqualToString:[AddDrinkContext liquorType]]){
            
            [self setTitle:@"Drink"];
            
            [self setType:@"Liquor"];
            
            self.standardSize = [[NSMeasurement alloc] initWithDoubleValue:1.5
                                                                      unit:[NSUnitVolume fluidOunces]];
            self.standardContent = 0.4;
            
            self.suggestions = @[[[NSMeasurement alloc] initWithDoubleValue:1.0
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:1.5
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:3.0
                                                                       unit:[NSUnitVolume fluidOunces]],
                                 [[NSMeasurement alloc] initWithDoubleValue:4.0
                                                                       unit:[NSUnitVolume fluidOunces]]];
        }
        
        self.size = self.standardSize;
        self.content = self.standardContent;
        
        self.time = [NSDate date];
    }
    
    return self;
}

- (NSArray *)getSuggestionsInMetric:(BOOL)metric
{
    if (metric) {
        NSMutableArray *mutableSuggestions = [NSMutableArray new];
        for (NSMeasurement *measurement in self.suggestions) {
            [mutableSuggestions addObject:[measurement measurementByConvertingToUnit:[NSUnitVolume milliliters]]];
        }
        return mutableSuggestions;
    } else {
        return self.suggestions;
    }
}

- (NSString *)titleForStandard:(BOOL)metric
{
    NSMeasurement *measurement;
    if (metric) {
        measurement = [self.standardSize measurementByConvertingToUnit:[NSUnitVolume milliliters]];
    } else {
        measurement = self.standardSize;
    }
    return [self titleForMeasurement:measurement];
}

- (NSArray *)suggestionStrings:(BOOL)metric
{
    NSMutableArray *ret = [[self suggestionStringsDefaultOnly:metric] mutableCopy];
    [ret addObject:@"Other"];
    return ret;
}

- (NSArray *)suggestionStringsDefaultOnly:(BOOL)metric
{
    NSArray *suggestions = [self getSuggestionsInMetric:metric];
    NSMutableArray *ret = [NSMutableArray new];
    for (NSMeasurement *measurement in suggestions) {
        [ret addObject:[self titleForMeasurement:measurement]];
    }
    return ret;
}

- (NSNumber *)getMult
{
    double mult = 1.0;
    double sizeAdj = (self.size.doubleValue / self.standardSize.doubleValue);
    double contentAdj = self.content / self.standardContent;
    mult = mult * sizeAdj * contentAdj;
    return [NSNumber numberWithDouble:mult];
}

-(NSString *)titleForSize:(BOOL)metric{
    return [self titleForMeasurement:metric ? [self sizeInmL] : [self sizeInOz]];
}

-(NSString *)titleForMeasurement:(NSMeasurement *)measurement {
    
    NSMeasurementFormatter *mf = [[NSMeasurementFormatter alloc] init];
    [mf setUnitStyle:NSFormattingUnitStyleShort];
    [mf setUnitOptions:NSMeasurementFormatterUnitOptionsProvidedUnit];
    NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
    [nf setMaximumFractionDigits:0];
    [mf setNumberFormatter:nf];
    return [mf stringFromMeasurement:measurement];
}

- (NSMeasurement *)sizeInOz
{
    return [self.size measurementByConvertingToUnit:[NSUnitVolume fluidOunces]];
}

- (NSMeasurement *)sizeInmL
{
    return [self.size measurementByConvertingToUnit:[NSUnitVolume milliliters]];
}

+(NSString *)beerType{
    return @"beer";
}
+(NSString *)wineType;{
    return @"wine";
}
+(NSString *)liquorType{
    return @"liquor";
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.type = [aDecoder decodeObjectForKey:@"type"];
    self.size = [aDecoder decodeObjectForKey:@"size"];
    self.time = [aDecoder decodeObjectForKey:@"time"];
    self.standardSize = [aDecoder decodeObjectForKey:@"standardSize"];
    self.standardContent = [aDecoder decodeDoubleForKey:@"standardContent"];
    self.content = [aDecoder decodeDoubleForKey:@"content"];
    self.suggestions = [aDecoder decodeObjectForKey:@"suggestions"];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.title
                  forKey:@"title"];
    [aCoder encodeObject:self.type
                  forKey:@"type"];
    [aCoder encodeObject:self.size
                  forKey:@"size"];
    [aCoder encodeObject:self.time
                  forKey:@"time"];
    [aCoder encodeObject:self.standardSize
                  forKey:@"standardSize"];
    [aCoder encodeDouble:self.standardContent
                  forKey:@"standardContent"];
    [aCoder encodeDouble:self.content
                  forKey:@"content"];
    [aCoder encodeObject:self.suggestions
                  forKey:@"suggestions"];
}

@end
