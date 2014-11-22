//
//  ProfileViewController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/28/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "ProfileViewController.h"
#import "AppDelegate.h"
#import "StoredDataManager.h"
#import "ActionSheetStringPicker.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
{
    HKHealthStore *healthStore;
    NSInteger sex;
    double weight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    healthStore = [(AppDelegate *)[UIApplication sharedApplication].delegate healthStore];
    sex = [[[StoredDataManager sharedInstance] getSex] integerValue];
    weight = [[[StoredDataManager sharedInstance] getWeight] doubleValue];
    [self.weightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.sexButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f", weight]
                       forState:UIControlStateNormal];
    [self.sexButton setTitle:[self stringForSex]
                    forState:UIControlStateNormal];
}

-(NSString *)stringForSex{
    if (sex == HKBiologicalSexFemale){
        return @"Female";
    } else if (sex == HKBiologicalSexMale){
        return @"Male";
    } else {
        return @"Other";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressWeight:(id)sender {
    UIAlertController *updateWeight = [UIAlertController alertControllerWithTitle:@"Update Weight" message:@"How would you like to update weight? If you select Health, your weight will automatically update to match the latest Health data." preferredStyle:UIAlertControllerStyleActionSheet];
    [updateWeight addAction:[UIAlertAction actionWithTitle:@"Enter Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        UIAlertController *confirmManual = [UIAlertController alertControllerWithTitle:@"Enter Weight Manually" message:@"Are you sure you want to enter your weight manually? Using Health allows info to stay up to date and accurate" preferredStyle:UIAlertControllerStyleAlert];
        [confirmManual addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [confirmManual addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self getManualWeight];
        }]];
        [self presentViewController:confirmManual animated:YES completion:nil];
    }]];
    [updateWeight addAction:[UIAlertAction actionWithTitle:@"Use Health" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], nil] completion:^(BOOL success, NSError *error){
            if (success) {
                [self performWeightQuery];
            }
        }];
    }]];
    [updateWeight addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:updateWeight animated:YES completion:nil];
}

-(void)getManualWeight{
    UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
    }];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                    if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
                                                        weight = [[enterWeight textFields][0] text].doubleValue;
                                                        [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                    forKey:[StoredDataManager weightKey]];
                                                        [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f", weight]
                                                                           forState:UIControlStateNormal];
                                                    } else {
                                                        [self presentViewController:enterWeight animated:YES completion:nil];
                                                    }
                                                  }]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:enterWeight
                           animated:YES
                         completion:nil];
    });
}

-(void)performWeightQuery{
    HKSampleQuery *weightQuery = [[HKSampleQuery alloc] initWithSampleType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass] predicate:nil limit:1 sortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO]] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if (!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results.count == 0){
                    UIAlertController *noWeightData = [UIAlertController alertControllerWithTitle:@"No Weight Data" message:@"There is no weight data available from Health. To proceed you must add weight data into the Health app, or enter manually without saving to Health." preferredStyle:UIAlertControllerStyleActionSheet];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Add to Health" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [healthStore requestAuthorizationToShareTypes:[NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass], nil] readTypes:nil completion:^(BOOL success, NSError *error){
                            if ([healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]] == HKAuthorizationStatusSharingAuthorized){
                                UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight" message:@"Enter in lbs." preferredStyle:UIAlertControllerStyleAlert];
                                [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
                                    [textField setKeyboardType:UIKeyboardTypeDecimalPad];
                                }];
                                [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                                [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                    if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
                                        weight = [[enterWeight textFields][0] text].doubleValue;
                                        HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
                                        HKQuantitySample *weightQuantity = [HKQuantitySample quantitySampleWithType:type quantity:[HKQuantity quantityWithUnit:[HKUnit poundUnit] doubleValue:weight] startDate:[NSDate date] endDate:[NSDate date]];
                                        [healthStore saveObject:weightQuantity
                                                 withCompletion:nil];
                                        [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                                                forKey:[StoredDataManager weightKey]];
                                        [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f", weight] forState:UIControlStateNormal];
                                    } else {
                                        [self presentViewController:enterWeight animated:YES completion:nil];
                                    }
                                }]];
                                [self presentViewController:enterWeight animated:YES completion:nil];
                            } else {
                                UIAlertController *difficult = [UIAlertController alertControllerWithTitle:@"Cannot write to Health" message:@"Without access to Health this app will need to get your weight manually" preferredStyle:UIAlertControllerStyleAlert];
                                [difficult addAction:[UIAlertAction actionWithTitle:@"Enter Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                                    [self getManualWeight];
                                }]];
                            }
                        }];
                    }]];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Enter Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                        [self getManualWeight];
                    }]];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
                    [self presentViewController:noWeightData animated:YES completion:nil];
                } else {
                    weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f", weight] forState:UIControlStateNormal];
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                            forKey:[StoredDataManager weightKey]];
                }
            });
        }
    }];
    [healthStore executeQuery:weightQuery];
}

- (IBAction)pressSex:(id)sender {
    UIAlertController *updateSex = [UIAlertController alertControllerWithTitle:@"Update Sex" message:@"How would you like to update your sex?" preferredStyle:UIAlertControllerStyleActionSheet];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Select Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self selectSexManual];
    }]];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Use Health" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObject:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]] completion:^(BOOL success, NSError *error){
            dispatch_async(dispatch_get_main_queue(), ^{
                sex = [[healthStore biologicalSexWithError:nil] biologicalSex];
                HKBiologicalSexObject *sexObject = [healthStore biologicalSexWithError:nil];
                sex = [sexObject biologicalSex];
                if (sex == HKBiologicalSexNotSet){
                    UIAlertController *confirmOther = [UIAlertController alertControllerWithTitle:@"Confirm Sex"
                                                                                          message:@"Health indicates you identify as 'Other'. Is this correct?"
                                                                                   preferredStyle:UIAlertControllerStyleAlert];
                    [confirmOther addAction:[UIAlertAction actionWithTitle:@"Change"
                                                                     style:UIAlertActionStyleDestructive
                                                                   handler:^(UIAlertAction *action){
                                                                       dispatch_async(dispatch_get_main_queue(), ^{
                                                                           [self selectSexManual];
                                                                       });
                                                                   }]];
                    [confirmOther addAction:[UIAlertAction actionWithTitle:@"Confirm"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action){
                                                                       // Move on
                                                                       [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex]
                                                                                forKey:[StoredDataManager sexKey]];
                                                                       [self.sexButton setTitle:[self stringForSex]
                                                                                       forState:UIControlStateNormal];
                                                                   }]];
                    [self presentViewController:confirmOther
                                       animated:YES
                                     completion:nil];
                } else {
                    
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex]
                                                                            forKey:[StoredDataManager sexKey]];
                    [self.sexButton setTitle:[self stringForSex]
                                    forState:UIControlStateNormal];
                }
            });
            
        }];
    }]];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:updateSex animated:YES completion:nil];
}

-(void)selectSexManual{
    [ActionSheetStringPicker showPickerWithTitle:@"Select a Sex"
                                            rows:@[@"Male", @"Female", @"Other"]
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           if (selectedIndex == 0){
                                               sex = HKBiologicalSexMale;
                                           } else if (selectedIndex == 1) {
                                               sex = HKBiologicalSexFemale;
                                           } else {
                                               sex = HKBiologicalSexNotSet;
                                           }
                                           // Move On
                                           [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex]
                                                                                                   forKey:[StoredDataManager sexKey]];
                                           [self.sexButton setTitle:[self stringForSex]
                                                           forState:UIControlStateNormal];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.view];
    
}

- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
