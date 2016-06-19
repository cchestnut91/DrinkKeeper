//
//  DrinkingSession.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/22/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "DrinkingSession.h"

#import "StoredDataManager.h"
#import "HealthKitManager.h"

@implementation DrinkingSession

-(double)getCurrentBAC{
    
    if (self.timeline == nil) {
        [self updateBACTimeline];
    }
    
    NSDate *now = [NSDate date];
    
    if ([now compare:[[self.timeline lastObject] date]] == NSOrderedDescending) {
        return 0.0;
    }
    
    for (int i = 0; i < self.timeline.count; i++) {
        BACTimelineItem *item = [self.timeline objectAtIndex:i];
        if ([[item date] compare:now] == NSOrderedDescending) {
            return item.bac.doubleValue;
        }
    }
    
    return 0.0;
}

- (BACTimelineItem *)getCurrentTimelineEntry {
    
    NSDate *now = [NSDate date];
    
    if ([now compare:[[self.timeline lastObject] date]] == NSOrderedDescending) {
        return self.timeline.lastObject;
    }
    
    for (int i = 0; i < self.timeline.count; i++) {
        BACTimelineItem *item = [self.timeline objectAtIndex:i];
        if ([[item date] compare:now] == NSOrderedDescending) {
            return item;
        }
    }
    
    return nil;
}

- (NSArray *)getTimelineItemsBeforeDate:(NSDate *)date withLimit:(NSUInteger)limit {
    NSMutableArray *ret = [NSMutableArray new];
    int current = 0;
    for (int i = (int)self.timeline.count - 1; i >= 0; i--) {
        BACTimelineItem *item = [self.timeline objectAtIndex:i];
        if ([[item date] compare:date] == NSOrderedAscending) {
            current = i;
            [ret addObject:item];
        }
    }
    
    int remaining = (int)self.timeline.count - current;
    
    int workingLimit = limit > remaining ? remaining : (int)limit;
    
    for (int i = current; i > 0; i -= ceil((remaining / workingLimit))) {
        BACTimelineItem *item = [self.timeline objectAtIndex:i];
        [ret addObject:item];
    }
    
    while (ret.count > limit) {
        [ret removeObjectAtIndex:ret.count-2];
    }
    
    return ret;
}

- (NSArray *)getTimelineItemsAfterDate:(NSDate *)date withLimit:(NSUInteger)limit {
    NSMutableArray *ret = [NSMutableArray new];
    
    int currentIndex = 0;
    for (int i = 0; i < self.timeline.count; i++) {
        BACTimelineItem *item = [self.timeline objectAtIndex:i];
        if ([[item date] compare:date] == NSOrderedDescending) {
            currentIndex = i;
            break;
        }
    }
    
    int remaining = (int)self.timeline.count - currentIndex;
    
    double workingLimit = limit > remaining ? remaining : (int)limit;
    
    for (int i = currentIndex; i < self.timeline.count; i += ceil((remaining / workingLimit))) {
        BACTimelineItem *item = [self.timeline objectAtIndex:i];
        [ret addObject:item];
    }
    
    while (ret.count > limit) {
        [ret removeObjectAtIndex:ret.count-2];
    }
    
    return ret;
}

- (void)updateBACTimeline {
    
    // Define Constants
    double genderStandard = [[StoredDataManager sharedInstance] genderStandard];
    double kgweight =([[[StoredDataManager sharedInstance] getWeight] doubleValue] * 0.454);
    double weightMod = genderStandard * kgweight;
    
    // Calculation variables
    double consumed = 0;
    double bac = 0;
    
    double peakBac = 0;
    
    NSMutableArray *timeline = [[NSMutableArray alloc] init];
    
    BACTimelineItem *firstItem = [[BACTimelineItem alloc] initWithBAC:@0 andDate:[NSDate dateWithTimeInterval:-60 sinceDate:[[self.drinks firstObject] time]] andNumDrinks:@0];
    
    [timeline addObject:firstItem];
    
    // For each drink
    for (int i = 0; i < self.drinks.count; i++) {
        Drink *drink = [self.drinks objectAtIndex:i];
        
        // Calculate alcohol consumed
        consumed = [[drink multiplier] doubleValue];
        
        double startBac = (bac * 100) + (consumed / weightMod);
        bac = startBac;
        
        NSDate *drinkTime = [drink time];
        
        double metabolized = 0;
        bac = startBac - metabolized;
        if (bac <= 0.0) {
            bac = 0.0;
        } else {
            bac = bac / 100;
        }
        
        if (bac > peakBac) {
            peakBac = bac;
        }
        
        BACTimelineItem *lastItem = [[BACTimelineItem alloc] initWithBAC:[NSNumber numberWithDouble:bac] andDate:drinkTime andNumDrinks:[NSNumber numberWithInt:i + 1]];
        [timeline addObject:lastItem];
        
        int count = 1;
        
        if (self.drinks.count > i + 1) {
            // Calculate BAC until next drink
            
            NSDate *workingDate = [drink time];
            workingDate = drinkTime;
            while ([[NSDate dateWithTimeInterval:count * 60 sinceDate:drinkTime] timeIntervalSinceDate:[[self.drinks objectAtIndex:i + 1] time]] < 0) {
                metabolized = [[StoredDataManager sharedInstance] metabolismConstant] * (count * (1 / 60.0));
                bac = startBac - metabolized;
                if (bac <= 0.0) {
                    bac = 0.0;
                } else {
                    bac = bac / 100;
                }
                
                if (bac > peakBac) {
                    peakBac = bac;
                }
                
                BACTimelineItem *newItem = [[BACTimelineItem alloc] initWithBAC:[NSNumber numberWithDouble:bac] andDate:[NSDate dateWithTimeInterval:count * 60 sinceDate:drinkTime] andNumDrinks:[NSNumber numberWithInt:i + 1]];
                NSString *lastValue = [NSString stringWithFormat:@"%.3f", lastItem.bac.doubleValue * 100];
                NSString *newValue = [NSString stringWithFormat:@"%.3f", newItem.bac.doubleValue * 100];
                if (![newValue isEqualToString:lastValue]) {
                    [timeline addObject:newItem];
                }
                count++;
            }
            
        } else {
            // Calculate BAC until zero
            while (bac * 100 >= 0.001) {
                metabolized = [[StoredDataManager sharedInstance] metabolismConstant] * (count * (1 / 60.0));
                bac = startBac - metabolized;
                if (bac <= 0.0) {
                    bac = 0.0;
                } else {
                    bac = bac / 100;
                }
                
                if (bac > peakBac) {
                    peakBac = bac;
                }
                
                BACTimelineItem *newItem = [[BACTimelineItem alloc] initWithBAC:[NSNumber numberWithDouble:bac] andDate:[NSDate dateWithTimeInterval:count * 60 sinceDate:drinkTime] andNumDrinks:[NSNumber numberWithInt:i + 1]];
                [timeline addObject:newItem];
                count++;
            }
            
            BACTimelineItem *final = [[BACTimelineItem alloc] initWithBAC:@0 andDate:[NSDate dateWithTimeInterval:count * 60 sinceDate:drinkTime] andNumDrinks:@0];
            [timeline addObject:final];
        }
    }
    self.timeline = timeline;
    
    self.peak = [NSNumber numberWithDouble:peakBac];
    
    self.startTime = [[self.timeline firstObject] date];
    self.projectedEndTime = [[self.timeline lastObject] date];
    
    if (!self.fileName) {
        self.fileName = [NSString stringWithFormat:@"%f", [self.startTime timeIntervalSince1970]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"bacUpdated"
                                                        object:nil];
    [[StoredDataManager sharedInstance] saveDrinkingSession:self];

}

-(void)updateHangover:(NSNumber *)ratingIn{
    self.hangoverRating = ratingIn;
    [[StoredDataManager sharedInstance] saveDrinkingSession:self];
}

-(void)addDrinkToSession:(Drink *)drinkIn{
    if (!self.drinks){
        self.drinks = [[NSArray alloc] init];
    }
    if (!self.timeline) {
        self.timeline = [[NSMutableArray alloc] init];
    }
    self.drinks = [self.drinks arrayByAddingObject:drinkIn];
    self.drinks = [self.drinks sortedArrayUsingComparator:^NSComparisonResult(id  __nonnull obj1, id  __nonnull obj2) {
        return [[(Drink *)obj1 time] compare:[(Drink *)obj2 time]];
    }];
    [self updateBACTimeline];
}

-(void)removeLastDrink {
	NSMutableArray *replaceDrinks = [NSMutableArray new];
	for (Drink *drink in self.drinks) {
		if (![drink isEqual:[self.drinks lastObject]]){
			[replaceDrinks addObject:drink];
		}
	}
	
	self.drinks = [NSArray arrayWithArray:replaceDrinks];
	
    [self updateBACTimeline];
}

-(NSNumber *)totalDrinks{
    return [NSNumber numberWithInteger:[self.drinks count]];
}

-(NSNumber *)numBeers{
    int cnt = 0;
    for (Drink *drink in self.drinks){
        if ([[drink type] isEqualToString:@"Beer"]){
            cnt++;
        }
    }
    if (cnt == 0){
        return nil;
    }
    return [NSNumber numberWithInt:cnt];
}

-(NSNumber *)numWine{
    int cnt = 0;
    for (Drink *drink in self.drinks){
        if ([[drink type] isEqualToString:@"Wine"]){
            cnt++;
        }
    }
    if (cnt == 0){
        return nil;
    }
    return [NSNumber numberWithInt:cnt];
}

-(NSNumber *)numDrinks{
    int cnt = 0;
    for (Drink *drink in self.drinks){
        if ([[drink type] isEqualToString:@"Liquor"]){
            cnt++;
        }
    }
    if (cnt == 0){
        return nil;
    }
    return [NSNumber numberWithInt:cnt];
}

-(NSNumber *)peakValue{
    if (self.peak){
        return self.peak;
    }
    return nil;
}

- (BOOL)needsSaveToHealth {
    return !self.hasSavedToHealth && [self.projectedEndTime compare:[[UserPreferences sharedInstance] verTwoUpdated]] == NSOrderedDescending;
}

-(NSString *)hangoverRatingStringValue{
    return nil;
}

-(NSNumber *)hangoverRating{
// TODO Hangovers
    if (true){
        return nil;
    }
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    self.startTime = [aDecoder decodeObjectForKey:@"startTime"];
    self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
    self.projectedEndTime = [aDecoder decodeObjectForKey:@"projectedEnd"];
    self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
    self.bac = [aDecoder decodeObjectForKey:@"bac"];
    self.drinks = [aDecoder decodeObjectForKey:@"drinks"];
    self.peak = [aDecoder decodeObjectForKey:@"peak"];
    self.hangoverRating = [aDecoder decodeObjectForKey:@"hangover"];
    self.timeline = [aDecoder decodeObjectForKey:@"timeline"];
    self.hasSavedToHealth = [aDecoder decodeBoolForKey:@"savedToHealth"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.startTime forKey:@"startTime"];
    [aCoder encodeObject:self.endTime forKey:@"endTime"];
    [aCoder encodeObject:self.projectedEndTime forKey:@"projectedEnd"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.bac forKey:@"bac"];
    [aCoder encodeObject:self.drinks forKey:@"drinks"];
    [aCoder encodeObject:self.peak forKey:@"peak"];
    [aCoder encodeObject:self.hangoverRating forKey:@"hangover"];
    [aCoder encodeObject:self.timeline forKey:@"timeline"];
    [aCoder encodeBool:self.hasSavedToHealth forKey:@"savedToHealth"];
}

@end
