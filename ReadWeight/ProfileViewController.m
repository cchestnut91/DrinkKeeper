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
    NSInteger sex;
    double weight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        [self performWeightQuery];
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
    [[HealthKitManager sharedInstance] performWeightQueryWithCallback:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if (!error){
            dispatch_async(dispatch_get_main_queue(), ^{
                if (results.count == 0){
                    UIAlertController *noWeightData = [UIAlertController alertControllerWithTitle:@"No Weight Data"
                                                                                          message:@"There is no weight data available from Health. To proceed you must enter your weight."
                                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Enter Manually"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action){
                                                                       [self getManualWeight];
                                                                   }]];
                    [noWeightData addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                     style:UIAlertActionStyleCancel
                                                                   handler:nil]];
                    [self presentViewController:noWeightData
                                       animated:YES
                                     completion:nil];
                } else {
                    weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [self.weightButton setTitle:[NSString stringWithFormat:@"%.1f", weight]
                                       forState:UIControlStateNormal];
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                            forKey:[StoredDataManager weightKey]];
                }
            });
        } else {
// TODO Error handling
        }
    }];
}

- (IBAction)pressSex:(id)sender {
    UIAlertController *updateSex = [UIAlertController alertControllerWithTitle:@"Update Sex" message:@"How would you like to update your sex?" preferredStyle:UIAlertControllerStyleActionSheet];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Select Manually" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self selectSexManual];
    }]];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Use Health" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        sex = [[[HealthKitManager sharedInstance] performSexQuery] biologicalSex];
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
                                                               [self.sexButton setTitle:[HealthKitManager stringForSex]
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
