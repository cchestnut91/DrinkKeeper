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
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    
    [self.weightButton.layer setCornerRadius:40];
    [self.sexButton.layer setCornerRadius:40];
    [self.saveButton.layer setCornerRadius:40];
    
    // Do any additional setup after loading the view.
    
    [self updateStaticLabels];
    
    [self updateValueLabels];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateValueLabels)
                                                 name:@"healthValuesUpdated"
                                               object:nil];
    
    [[HealthKitManager sharedInstance] updateHealthValues];
    
}

-(void)updateStaticLabels{
    [self setTitle:@"Update Health Info"];
    
    [self.weightLabel setText:@"Weight"];
    [self.sexLabel setText:@"Sex"];
}

-(void)updateValueLabels{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        sex = [[[StoredDataManager sharedInstance] getSex] integerValue];
        weight = [[[StoredDataManager sharedInstance] getWeight] doubleValue];
        
        [self.weightValue setText:[NSString stringWithFormat:@"%.1f", weight]];
        [self.sexValue setText:[self stringForSex]];
    });
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

- (IBAction)pressWeight:(id)sender {
    
// TODO handle if Health unavailable on this device. Like, everywhere. Shit
    if ([[HealthKitManager sharedInstance] isHealthAvailable]){
        
    } else {
        
    }
    
    UIAlertController *updateWeight = [UIAlertController alertControllerWithTitle:@"Update Weight"
                                                                          message:@"How would you like to update weight? If you select Health, your weight will automatically update to match the latest Health app data."
                                                                   preferredStyle:UIAlertControllerStyleActionSheet];
    [updateWeight addAction:[UIAlertAction actionWithTitle:@"Enter Manually"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       [self getManualWeightWithMessage:nil];
                                                   }]];
    [updateWeight addAction:[UIAlertAction actionWithTitle:@"Use Health"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       [[HealthKitManager sharedInstance] setUserRequestsHealth:YES];
                                                       [self performWeightQuery];
                                                   }]];
    
    [updateWeight addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil]];
    [self presentViewController:updateWeight
                       animated:YES
                     completion:nil];
}

-(void)getManualWeightWithMessage:(NSString *)messageIn{
    UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight"
                                                                         message:messageIn
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
    }];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
    if (messageIn){
        [enterWeight addAction:[UIAlertAction actionWithTitle:@"Try Health Again"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                          [self performWeightQuery];
                                                      }]];
    }
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                    if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
                                                        weight = [[enterWeight textFields][0] text].doubleValue;
                                                        [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                    forKey:[StoredDataManager weightKey]];
                                                        [self.weightValue setText:[NSString stringWithFormat:@"%.1f", weight]];
                                                    } else {
                                                        [self presentViewController:enterWeight
                                                                           animated:YES
                                                                         completion:nil];
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
                    [self getManualWeightWithMessage:@"No Available Weight Data In Health. To adjust your sharing preferences, open the Health App, select Sources, and allow Drink Keeper to read weight data."];
                } else {
                    weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [self.weightValue setText:[NSString stringWithFormat:@"%.1f", weight]];
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
    UIAlertController *updateSex = [UIAlertController alertControllerWithTitle:@"Update Sex"
                                                                       message:@"How would you like to update your sex?"
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Select Manually"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [self selectSexManual];
                                                }]];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Use Health"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [[HealthKitManager sharedInstance] setUserRequestsHealth:YES];
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
                                                                                                           [self.sexValue setText:[HealthKitManager stringForSex]];
                                                                                                       }]];
                                                        
                                                        [self presentViewController:confirmOther
                                                                           animated:YES
                                                                         completion:nil];
                                                    } else {
                                                        
                                                        [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex]
                                                                                                                forKey:[StoredDataManager sexKey]];
                                                        [self.sexValue setText:[self stringForSex]];
                                                    }
                                                }]];
    [updateSex addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                  style:UIAlertActionStyleCancel
                                                handler:nil]];
    [self presentViewController:updateSex
                       animated:YES
                     completion:nil];
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
                                           [self.sexValue setText:[self stringForSex]];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.view];
    
}

- (IBAction)close:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES
                                                  completion:nil];
}
@end
