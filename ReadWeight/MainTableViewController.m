//
//  MainTableViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "MainTableViewController.h"
#import "AppDelegate.h"
#import "AddDrinkViewController.h"
#import "Drink.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController
{
    NSString *typePressed;
    double bac;
    NSString *bacFile;
    NSString *sessionFile;
    HKHealthStore *healthStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    healthStore = [(AppDelegate *)[UIApplication sharedApplication].delegate healthStore];
    HKSampleQuery *weightQuery = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass] predicate:nil limit:1 sortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO]] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if (!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results.count != 0){
                    double weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [JNKeychain saveValue:[NSNumber numberWithDouble:weight] forKey:@"weight"];
                }
            });
        }
    }];
    [healthStore executeQuery:weightQuery];
    bacFile = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"bac"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bacFile]){
        bac = [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithFile:bacFile] doubleValue];
    } else {
        bac = 0.0;
        [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:bac] toFile:bacFile];
    }
    sessionFile =[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"drinkingSession"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDrink:) name:@"newDrink" object:nil];
}

-(void)viewDidAppear:(BOOL)animated{
    if ([JNKeychain loadValueForKey:@"weight"] == nil || [JNKeychain loadValueForKey:@"sex"] == nil){
        [self performSegueWithIdentifier:@"getWeight" sender:self];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]){
        NSDictionary *drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"drinkingSession"]];
        NSArray *drinks = [drinkingSession objectForKey:@"drinks"];
        [self recalcBAC:drinks];
    }
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac]];
}

-(void)addDrink:(NSNotification *)notification{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil]];
    NSMutableDictionary *drinkingSession;
    NSDictionary *userInfo = [notification userInfo];
    Drink *newDrink = [userInfo objectForKey:@"newDrink"];
    if (bac == 0.0){
        drinkingSession = [[NSMutableDictionary alloc] init];
        [drinkingSession setObject:[newDrink time] forKey:@"startTime"];
        [drinkingSession setObject:[[NSArray alloc] init] forKey:@"drinks"];
    } else {
        drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"drinkingSession"]];
    }
    NSMutableArray *drinks = [NSMutableArray arrayWithArray:[drinkingSession objectForKey:@"drinks"]];
    [drinks addObject:newDrink];
    [drinkingSession setObject:drinks forKey:@"drinks"];
    [NSKeyedArchiver archiveRootObject:drinkingSession toFile:[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"drinkingSession"]];
    [self recalcBAC:drinks];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *sober = [[UILocalNotification alloc] init];
    double secondsLeft = (bac / 0.015) * 60 * 60;
    [sober setFireDate:[NSDate dateWithTimeIntervalSinceNow:secondsLeft]];
    [sober setAlertBody:@"BAC has reached 0.0"];
    [sober setSoundName:UILocalNotificationDefaultSoundName];
    [[UIApplication sharedApplication] scheduleLocalNotification:sober];
}

-(void)recalcBAC:(NSArray *)drinks{
    NSDictionary *drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"drinkingSession"]];
    double consumed = 0.0;
    for (Drink *drink in drinks){
        double add = [[drink multiplier] doubleValue];
        consumed += add;
    }
    consumed = consumed * 0.806;
    double genderStandard = [self genderStandard];
    double weightMod = genderStandard * ([[JNKeychain loadValueForKey:@"weight"] doubleValue] * 0.454);
    double newBac = consumed / weightMod;
    double hoursDrinking = [[NSDate date] timeIntervalSinceDate:[drinkingSession objectForKey:@"startTime"]] / 60.0 / 60.0;
    double metabolized = 0.015 * hoursDrinking;
    bac = newBac - metabolized;
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    HKQuantitySample *bacSample = [HKQuantitySample quantitySampleWithType:type quantity:[HKQuantity quantityWithUnit:[HKUnit percentUnit] doubleValue:bac] startDate:[NSDate date] endDate:[NSDate date]];
    [healthStore saveObject:bacSample withCompletion:nil];
    [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:bac] toFile:bacFile];
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac]];
    if (bac == 0.0){
        [[NSFileManager defaultManager] removeItemAtPath:sessionFile error:nil];
    }
}

-(double)genderStandard{
    NSInteger sex = [[JNKeychain loadValueForKey:@"sex"] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.68;
    } else if (sex == HKBiologicalSexFemale){
        return 0.55;
    } else {
        return 0.615;
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1){
        NSArray *types = @[@"Beer", @"Wine", @"Liquor"];
        typePressed = types[indexPath.row];
        [self performSegueWithIdentifier:@"addDrink" sender:self];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addDrink"]){
        [(AddDrinkViewController *)segue.destinationViewController setType:typePressed];
    }
}


@end