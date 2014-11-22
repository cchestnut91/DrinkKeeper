//
//  TodayViewController.m
//  Add Drinks
//
//  Created by Calvin Chestnut on 9/27/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "Drink.h"
#import "StoredDataManager.h"
#import "JNKeychain.h"
#import <HealthKit/HealthKit.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController {
    double bac;
    NSString *bacFile;
    NSString *sessionFile;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"];
    bacFile = [[containerURL URLByAppendingPathComponent:@"bac"] path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bacFile]){
        bac = [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithFile:bacFile] doubleValue];
    } else {
        bac = 0.0;
        [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:bac] toFile:bacFile];
    }
    sessionFile = [[containerURL URLByAppendingPathComponent:@"drinkingSession"] path ];
    if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]){
        [self reloadBAC];
    }
}

-(double)metabolismConstant{
    NSInteger sex = [[[StoredDataManager sharedInstance] getSex] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.015;
    } else if (sex == HKBiologicalSexFemale){
        return 0.017;
    } else {
        return 0.016;
    }
}

-(double)genderStandard{
    NSInteger sex = [[[StoredDataManager sharedInstance] getSex] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.58;
    } else if (sex == HKBiologicalSexFemale){
        return 0.49;
    } else {
        return 0.535;
    }
}

-(void)reloadBAC{
    NSDictionary *drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:sessionFile];
    NSArray *drinks = [drinkingSession objectForKey:@"drinks"];
    double consumed = 0.0;
    for (Drink *drink in drinks){
        double add = [[drink multiplier] doubleValue];
        consumed += add;
    }
    consumed = consumed * 0.806 * 1.2;
    double genderStandard = [self genderStandard];
    double kgweight =([[[StoredDataManager sharedInstance] getWeight] doubleValue] * 0.454);
    double weightMod = genderStandard * kgweight;
    double newBac = consumed / weightMod;
    double hoursDrinking = [[NSDate date] timeIntervalSinceDate:[drinkingSession objectForKey:@"startTime"]] / 60.0 / 60.0;
    double metabolized = [self metabolismConstant] * hoursDrinking;
    bac = newBac - metabolized;
    if (bac <= 0.0){
        [[NSFileManager defaultManager] removeItemAtPath:sessionFile error:nil];
        bac = 0.0;
    }
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
        if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]){
            completionHandler(NCUpdateResultNewData);
        } else {
            completionHandler(NCUpdateResultNoData);
        }
    }
    completionHandler(NCUpdateResultNewData);
}
@end
