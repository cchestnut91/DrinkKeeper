//
//  SessionDetailsController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "SessionDetailsController.h"

@implementation SessionDetailsController

- (id)init{
	self = [super init];
	
	return self;
}

- (void)awakeWithContext:(id)context{
	self.session = (DrinkingSession *)context;
	
	[self updateLabels];
}

-(void)updateLabels{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    
    if ([self.session startTime]){
        [self.startedGroup setHidden:NO];
        
        [self.startedTitle setText:@"Started"];
        [self.startedValue setText:[formatter stringFromDate:self.session.startTime]];
    } else {
        [self.startedGroup setHidden:YES];
    }
    
    if ([self.session endTime]){
        [self.endedGroup setHidden:NO];
        
        [self.endedTitle setText:@"Finished"];
        [self.endedValue setText:[formatter stringFromDate:self.session.endTime]];
    } else {
        [self.endedGroup setHidden:YES];
    }
    
    if ([self.session totalDrinks]){
        [self.totalGroup setHidden:NO];
        
        [self.totalTitle setText:@"Total Drinks"];
        [self.totalValue setText:[NSString stringWithFormat:@"%d", [[self.session totalDrinks] intValue]]];
    } else {
        [self.totalGroup setHidden:YES];
    }
    
    if ([self.session numBeers]){
        [self.beersGroup setHidden:NO];
        
        [self.beersTitle setText:@"Beers"];
        [self.beersValue setText:[NSString stringWithFormat:@"%d", [[self.session numBeers] intValue]]];
    } else {
        [self.beersGroup setHidden:YES];
    }
    
    if ([self.session numWine]){
        [self.wineGroup setHidden:NO];
        
        [self.wineTitle setText:@"Wine Glasses"];
        [self.wineValue setText:[NSString stringWithFormat:@"%d", [[self.session numWine] intValue]]];
    } else {
        [self.wineGroup setHidden:YES];
    }
    
    if ([self.session numDrinks]){
        [self.drinksGroup setHidden:NO];
        
        [self.drinksTitle setText:@"Drinks / Shots"];
        [self.drinksValue setText:[NSString stringWithFormat:@"%d", [[self.session numDrinks] intValue]]];
    } else {
        [self.drinksGroup setHidden:YES];
    }
    
    if ([self.session peakValue]){
        [self.peakGroup setHidden:NO];
        
        [self.peakTitle setText:@"Peak BAC"];
        [self.peakValue setText:[NSString stringWithFormat:@"%.3f", [[self.session peakValue] doubleValue] * 100]];
    } else {
        [self.peakGroup setHidden:YES];
    }
    
    if ([self.session hangoverRating]){
        [self.hangoverGroup setHidden:NO];
        
        [self.hangoverTitle setText:@"Hangover Rating"];
        [self.hangoverValue setText:[self.session hangoverRatingStringValue]];
    } else {
        [self.hangoverGroup setHidden:YES];
    }
}

@end
