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
    NSURL *containerURL = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.calvinchestnut.drinktracker.sessionData"];
    bacFile = [[containerURL URLByAppendingPathComponent:@"bac"] path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:bacFile]){
        bac = [(NSNumber *)[NSKeyedUnarchiver unarchiveObjectWithFile:bacFile] doubleValue];
    } else {
        bac = 0.0;
        [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:bac] toFile:bacFile];
    }
    sessionFile = [[containerURL URLByAppendingPathComponent:@"drinkingSession"] path ];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDrink:) name:@"newDrink" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDrinkFromURL:) name:@"addFromURL" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkLaunchURL" object:nil];
}

-(void)addDrinkFromURL:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    typePressed = [userInfo objectForKey:@"type"];
    [self performSegueWithIdentifier:@"addDrink" sender:self];
}

-(void)viewDidAppear:(BOOL)animated{
    if ([JNKeychain loadValueForKey:@"weight"] == nil || [JNKeychain loadValueForKey:@"sex"] == nil){
        [self performSegueWithIdentifier:@"getWeight" sender:self];
    } else {
        [healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent]] readTypes:[NSSet setWithObjects:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex], [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], nil] completion:^(BOOL success, NSError *error){
        }];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:sessionFile]){
        NSDictionary *drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:sessionFile];
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
        drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:sessionFile];
    }
    NSMutableArray *drinks = [NSMutableArray arrayWithArray:[drinkingSession objectForKey:@"drinks"]];
    [drinks addObject:newDrink];
    [drinkingSession setObject:drinks forKey:@"drinks"];
    [NSKeyedArchiver archiveRootObject:drinkingSession toFile:sessionFile];
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
    NSDictionary *drinkingSession = [NSKeyedUnarchiver unarchiveObjectWithFile:sessionFile];
    double consumed = 0.0;
    for (Drink *drink in drinks){
        double add = [[drink multiplier] doubleValue];
        consumed += add;
    }
    consumed = consumed * 0.806 * 1.2;
    double genderStandard = [self genderStandard];
    double kgweight =([[JNKeychain loadValueForKey:@"weight"] doubleValue] * 0.454);
    double weightMod = genderStandard * kgweight;
    double newBac = consumed / weightMod;
    double hoursDrinking = [[NSDate date] timeIntervalSinceDate:[drinkingSession objectForKey:@"startTime"]] / 60.0 / 60.0;
    double metabolized = [self metabolismConstant] * hoursDrinking;
    bac = newBac - metabolized;
    if (bac <= 0.0){
        [[NSFileManager defaultManager] removeItemAtPath:sessionFile error:nil];
        bac = 0.0;
    }
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent];
    HKQuantitySample *bacSample = [HKQuantitySample quantitySampleWithType:type quantity:[HKQuantity quantityWithUnit:[HKUnit percentUnit] doubleValue:bac / 100] startDate:[NSDate date] endDate:[NSDate date]];
    [healthStore saveObject:bacSample withCompletion:nil];
    [NSKeyedArchiver archiveRootObject:[NSNumber numberWithDouble:bac] toFile:bacFile];
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac]];
}

-(double)metabolismConstant{
    NSInteger sex = [[JNKeychain loadValueForKey:@"sex"] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.015;
    } else if (sex == HKBiologicalSexFemale){
        return 0.017;
    } else {
        return 0.016;
    }
}

-(double)genderStandard{
    NSInteger sex = [[JNKeychain loadValueForKey:@"sex"] integerValue];
    if (sex == HKBiologicalSexMale){
        return 0.58;
    } else if (sex == HKBiologicalSexFemale){
        return 0.49;
    } else {
        return 0.535;
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
