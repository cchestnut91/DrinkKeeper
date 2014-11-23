//
//  AddDrinkController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AddDrinkController.h"

@implementation AddDrinkController {
    NSDateFormatter *formatter;
}

-(instancetype)initWithContext:(id)context{
    self = [super initWithContext:context];
    if (self){
        self.drinkContext = (AddDrinkContext *)context;
        if (self.drinkContext.title){
            [self setTitle:self.drinkContext.title];
        }
        if ([[self.drinkContext strengthOptions] count] == 4){
            [self.threeOptionSlider setHidden:YES];
            self.strengthSlider = self.fourOptionSlider;
            [self.fourOptionSlider setHidden:NO];
        } else {
            [self.threeOptionSlider setHidden:NO];
            self.strengthSlider = self.threeOptionSlider;
            [self.fourOptionSlider setHidden:YES];
        }
        if (![[self.drinkContext type] isEqualToString:@"Beer"]){
            [self.strengthSlider setValue:1];
            [self.strengthPreviewLabel setText:[[self.drinkContext optionLabels] objectAtIndex:1]];
        } else {
            [self.strengthPreviewLabel setText:[[self.drinkContext optionLabels] firstObject]];
        }
        
        if (![[self.drinkContext type] isEqualToString:@"Liquor"]){
            [self.strengthLabel setText:@"Size"];
        }
        
        
        [self.whenSlider setValue:19];
        
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"h:mm a"];
        
        [self.whenPreview setText:[formatter stringFromDate:self.drinkContext.time]];
    }
    return self;
}

-(void)willActivate{
    
}

- (IBAction)sizeValueChanged:(float)value {
    NSLog(@"%f", value);
    NSInteger index = [[NSNumber numberWithFloat:value] integerValue];
    [self.drinkContext setSelectedMult:[[self.drinkContext strengthOptions] objectAtIndex:index]];
    [self.strengthPreviewLabel setText:[[self.drinkContext optionLabels] objectAtIndex:index]];
}

- (IBAction)whenValueChanged:(float)value {
    NSLog(@"%f", value);
    int mult = 20 - value - 1;
    int secondsAgo = 5 * 60 * mult;
    
    [self.drinkContext setTime:[NSDate dateWithTimeIntervalSinceNow:-1 * secondsAgo]];
    
    if (secondsAgo == 0){
        [self.whenRelativeLabel setText:@"Now"];
    } else {
        [self.whenRelativeLabel setText:[NSString stringWithFormat:@"%d min. ago", secondsAgo / 60]];
    }
    [self.whenPreview setText:[formatter stringFromDate:[self.drinkContext time]]];
}

- (IBAction)addDrink {
    Drink *newDrink = [[Drink alloc] initWithDrinkContext:self.drinkContext];
    
    [[StoredDataManager sharedInstance] addDrinkToCurrentSession:newDrink];
    [self popToRootController];
}
@end
