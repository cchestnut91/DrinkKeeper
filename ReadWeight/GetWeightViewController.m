//
//  GetWeightViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "GetWeightViewController.h"
#import "AppDelegate.h"

@interface GetWeightViewController ()

@end

@implementation GetWeightViewController{
    double weight;
    HKHealthStore *healthStore;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.indicator = [[TransLoadingIndicator alloc] init];
    healthStore = [(AppDelegate *)[UIApplication sharedApplication].delegate healthStore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressManual:(id)sender {
    UIAlertController *confirmManual = [UIAlertController alertControllerWithTitle:@"Enter Weight Manually" message:@"Are you sure you want to enter your weight manually? Using Health allows info to stay up to date and accurate" preferredStyle:UIAlertControllerStyleAlert];
    [confirmManual addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [confirmManual addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
            [textField setKeyboardType:UIKeyboardTypeDecimalPad];
        }];
        [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
                weight = [[enterWeight textFields][0] text].doubleValue;
                [JNKeychain saveValue:[NSNumber numberWithDouble:weight] forKey:@"weight"];
                [self performSegueWithIdentifier:@"getSex" sender:self];
            } else {
                [self presentViewController:enterWeight animated:YES completion:nil];
            }
        }]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:enterWeight animated:YES completion:nil];
        });
    }]];
    [self presentViewController:confirmManual animated:YES completion:nil];
}

- (IBAction)pressHealth:(id)sender {
    [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], nil] completion:^(BOOL success, NSError *error){
        if (success) {
            [self performWeightQuery];
        }
    }];
}

-(void)performWeightQuery{
    HKSampleQuery *weightQuery = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass] predicate:nil limit:1 sortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO]] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        [self.indicator hide];
        if (!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results.count == 0){
                    UIAlertController *noWeightData = [UIAlertController alertControllerWithTitle:@"No Weight Data" message:@"There is no weight data available from Health. To proceed you must add weight data into the Health app, or enter manually without saving to Health." preferredStyle:UIAlertControllerStyleActionSheet];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Add to Health" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [healthStore requestAuthorizationToShareTypes:[NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], nil] readTypes:nil completion:^(BOOL success, NSError *error){
                            if ([healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]] == HKAuthorizationStatusSharingAuthorized){
                                UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight" message:nil preferredStyle:UIAlertControllerStyleAlert];
                                [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
                                    [textField setKeyboardType:UIKeyboardTypeDecimalPad];
                                }];
                                [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                                [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                    if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
                                        weight = [[enterWeight textFields][0] text].doubleValue;
                                        HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
                                        HKQuantitySample *weightQuantity = [HKQuantitySample quantitySampleWithType:type quantity:[HKQuantity quantityWithUnit:[HKUnit poundUnit] doubleValue:weight] startDate:[NSDate date] endDate:[NSDate date]];
                                        [healthStore saveObject:weightQuantity withCompletion:nil];
                                        [JNKeychain saveValue:[NSNumber numberWithDouble:weight] forKey:@"weight"];
                                        [self performSegueWithIdentifier:@"getSex" sender:self];
                                    } else {
                                        [self presentViewController:enterWeight animated:YES completion:nil];
                                    }
                                }]];
                                [self presentViewController:enterWeight animated:YES completion:nil];
                            } else {
                                UIAlertController *difficult = [UIAlertController alertControllerWithTitle:@"Cannot write to Health" message:@"Without access to Health this app will need to get your weight manually" preferredStyle:UIAlertControllerStyleAlert];
                                [difficult addAction:[UIAlertAction actionWithTitle:@"Enter Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                    [self pressManual:self];
                                }]];
                            }
                        }];
                    }]];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Enter Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [self pressManual:self];
                    }]];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:noWeightData animated:YES completion:nil];
                } else {
                    weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [JNKeychain saveValue:[NSNumber numberWithDouble:weight] forKey:@"weight"];
                    [self performSegueWithIdentifier:@"getSex" sender:self];
                }
            });
        }
    }];
    [self.indicator setUp];
    [healthStore executeQuery:weightQuery];
    [self.indicator startAnimating];
}

@end
