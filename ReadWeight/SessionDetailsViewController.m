//
//  SessionDetailsViewController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/13/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "SessionDetailsViewController.h"

@interface SessionDetailsViewController ()

@end

@implementation SessionDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.lineChartView setDataSource:self];
    [self.lineChartView setDelegate:self];
    
    UIColor *customRed = [UIColor colorWithRed:229/255.0 green:48/255.0 blue:75/255.0 alpha:1];
    
    [self.lineChartView setChartBackgroundColor:customRed];
    
    [self.lineChartView setGridIntervalFontColor:[UIColor whiteColor]];
    [self.lineChartView setGridIntervalLinesColor:[UIColor whiteColor]];
    
    [self.lineChartView setLineColor:[UIColor whiteColor]];
    [self.lineChartView setElementFillColor:customRed];
    [self.lineChartView setElementStrokeColor:[UIColor whiteColor]];
    
    NSTimeInterval time;
    
    if ([self.session endTime]){
        
        time = [[self.session endTime] timeIntervalSinceDate:[self.session startTime]];
        
    } else if ([self.session projectedEndTime] && [self.session getCurrentBAC] == 0.0){
        
        [self.session setEndTime:[self.session projectedEndTime]];
        time = [[self.session endTime] timeIntervalSinceDate:[self.session startTime]];
        
    } else {
        
        time = [[NSDate date] timeIntervalSinceDate:[self.session startTime]];
        
    }
    
    int numMinutes = time / 60.0;
    int numHours = numMinutes / 60;
    
    if (numHours > 0){
        
        numMinutes = numMinutes - (numHours * 60);
        
        if (numMinutes > 9){
            [self.mainSessionHeader setText:[NSString stringWithFormat:@"%d:%d Hours", numHours, numMinutes]];
        } else {
            [self.mainSessionHeader setText:[NSString stringWithFormat:@"%d:0%d Hours", numHours, numMinutes]];
        }
        
    } else {
        
        if (numMinutes == 0){
            [self.mainSessionHeader setText:@"Just Started"];
        } else {
            NSString *minuteText = numMinutes == 1 ? @"Minute" : @"Minutes";
            [self.mainSessionHeader setText:[NSString stringWithFormat:@"%d %@", numMinutes, minuteText]];
        }
        
    }
    
    [self.numDrinksLabel setText:@"Total Drinks"];
    [self.numDrinksValue setText:[NSString stringWithFormat:@"%@", [self.session totalDrinks]]];
    
    [self.peakBACLabel setText:@"Peak B.A.C."];
    [self.peakBACValue setText:[NSString stringWithFormat:@"%.3f", [[self.session peakValue] floatValue] * 100]];
    
    NSNumber *beers = [self.session numBeers];
    NSNumber *wines = [self.session numWine];
    NSNumber *drinks = [self.session numDrinks];
    
    if (!beers.boolValue) {
        self.numBeerHeight.constant = 0;
    }
    [self.numBeerView setHidden:!beers.boolValue];
    [self.numBeerLabel setText:@"Number of Beers"];
    [self.numBeerValue setText:[NSString stringWithFormat:@"%@", beers]];
    
    if (!wines.boolValue) {
        self.numWineHeight.constant = 0;
    }
    [self.numWineView setHidden:!wines.boolValue];
    [self.numWineLabel setText:@"Glasses of Wine"];
    [self.numWineValue setText:[NSString stringWithFormat:@"%@", wines]];
    
    if (!drinks.boolValue) {
        self.numLiquorHeight.constant = 0;
    }
    [self.numLiquorView setHidden:!drinks.boolValue];
    [self.nulLiquorLabel setText:@"Liquor Drinks"];
    [self.numLIquorValue setText:[NSString stringWithFormat:@"%@", drinks]];
}

-(NSUInteger)numberOfElementsInChartView:(ANDLineChartView *)chartView {
    return [[self.session timeline] count] / 5;
}

-(CGFloat)chartView:(ANDLineChartView *)chartView valueForElementAtRow:(NSUInteger)row {
    return [[(BACTimelineItem *)[[self.session timeline] objectAtIndex:row * 5] bac] floatValue];
}

- (NSUInteger)numberOfGridIntervalsInChartView:(ANDLineChartView *)chartView {
    CGFloat peak = [[self.session peak] doubleValue];
    
    int ret = ((peak + 0.00005) / 0.0001) + 1;
    return ret > 10 ? 10 : ret;
}

- (NSString*)chartView:(ANDLineChartView *)chartView descriptionForGridIntervalValue:(CGFloat)interval {
    return [NSString stringWithFormat:@"%.3f", interval * 100];
}

- (CGFloat)maxValueForGridIntervalInChartView:(ANDLineChartView *)chartView {
    CGFloat peak = [[self.session peak] doubleValue];
    return peak + 0.00005;
}

- (CGFloat)minValueForGridIntervalInChartView:(ANDLineChartView *)chartView {
    return 0.0;
}

- (void)didStartReloadingChart {
    [self.chartLoadingView setHidden:NO];
}

- (void)didFinishReloadingChart {
    [self.chartLoadingView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
