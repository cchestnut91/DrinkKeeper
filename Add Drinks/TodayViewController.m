//
//  TodayViewController.m
//  Add Drinks
//
//  Created by Calvin Chestnut on 9/27/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "TodayViewController.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    double bac;
    DrinkingSession *session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self reloadBAC];
}

-(void)reloadBAC{
    bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac]];
}

- (IBAction)addBeer:(id)sender {
    [self.extensionContext openURL:[NSURL URLWithString:@"addDrink://?type=Beer"] completionHandler:nil];
}

- (IBAction)addWine:(id)sender {
    [self.extensionContext openURL:[NSURL URLWithString:@"addDrink://?type=Wine"] completionHandler:nil];
}

- (IBAction)addLiquor:(id)sender {
    [self.extensionContext openURL:[NSURL URLWithString:@"addDrink://?type=Liquor"] completionHandler:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    // Perform any setup necessary in order to update the view.
    if (bac != 0){
        completionHandler(NCUpdateResultNewData);
    } else {
        if ([[StoredDataManager sharedInstance] currentSession]){
            completionHandler(NCUpdateResultNewData);
        } else {
            completionHandler(NCUpdateResultNoData);
        }
    }
    completionHandler(NCUpdateResultNewData);
}
@end
