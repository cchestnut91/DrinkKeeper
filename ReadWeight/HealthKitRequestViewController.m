//
//  HealthKitRequestViewController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/19/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "HealthKitRequestViewController.h"
#import "HealthKitManager.h"
#import "StoredDataManager.h"
#import "ActionSheetStringPicker.h"
#import <HealthKit/HealthKit.h>

@interface HealthKitRequestViewController ()

@end

@implementation HealthKitRequestViewController{
    double weight;
    NSArray *weightQueryResults;
    HKBiologicalSexObject *userSex;
    BOOL noWeightData;
    BOOL noSexData;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    noWeightData = NO;
    noSexData = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleManualPressed:(id)sender {
    noSexData = YES;
    [self getWeightManually];
}

-(void)getWeightManually{
    // Get Weight
    UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
    }];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
            
// TODO check if string is valid double value
            weight = [[enterWeight textFields][0] text].doubleValue;
            
            [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                    forKey:[StoredDataManager weightKey]];
            
            if (userSex == nil){
                noSexData = YES;
            }
            if (noSexData){
                [self getSexManually];
            }
        } else {
            [self presentViewController:enterWeight animated:YES completion:nil];
        }
    }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:enterWeight animated:YES completion:nil];
    });
}

-(void)getSexManually{
    // Get Sex
    
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Sex"
                                            rows:@[@"Male", @"Female", @"Other"]
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           HKBiologicalSex sex;
                                           if (selectedIndex == 0){
                                               sex = [HealthKitManager sexForNumber:2];
                                           } else if (selectedIndex == 1) {
                                               sex = [HealthKitManager sexForNumber:1];
                                           } else {
                                               sex = [HealthKitManager sexForNumber:0];
                                           }
                                           [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex] forKey:[StoredDataManager sexKey]];
//TODO Move on to next View
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.useManualButton];
}

- (IBAction)handleHealthPressed:(id)sender {
    
    [[HealthKitManager sharedInstance] performHealthKitRequestWithCallback:^(BOOL success, NSError *error){
        if (success) {
            [self performQueries];
        }
    }];
}

-(void)performQueries{
    [[HealthKitManager sharedInstance] performWeightQueryWithCallback:^(HKSampleQuery *query, NSArray *results, NSError *error){
        [self.loadingView hide];
        if (!error){
            weightQueryResults = results;
            userSex = [[HealthKitManager sharedInstance] performSexQuery];
            
            if (results.count == 0 || [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]] == 0){
                noWeightData = YES;
            }
            if (userSex == nil || [userSex biologicalSex] == HKBiologicalSexNotSet) {
                noSexData = YES;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (noWeightData){
                    UIAlertController *noWeightAlert = [UIAlertController alertControllerWithTitle:@"No Weight Data"
                                                                                          message:@"There is no weight data available from Health. To proceed you must add your weight."
                                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
                    [noWeightAlert addAction:[UIAlertAction actionWithTitle:@"Enter Weight"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action){
                                                                       [self getWeightManually];
                                                                   }]];
                    [noWeightAlert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                      style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:noWeightAlert
                                       animated:YES
                                     completion:nil];
                } else {
                    weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                            forKey:[StoredDataManager weightKey]];
                    if (noSexData){
                        [self getSexManually];
                    } else {
                        [[StoredDataManager sharedInstance] updateDictionaryWithObject:userSex
                                                                                forKey:[StoredDataManager sexKey]];
                    }
                }
            });
        }
    }];
}

@end
