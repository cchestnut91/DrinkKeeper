//
//  HealthKitRequestViewController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/19/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "HealthKitRequestViewController.h"
#import "HealthKitManager.h"
#import "AppDelegate.h"
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
	__weak IBOutlet NSLayoutConstraint *infoButtonPositionA;
	__weak IBOutlet NSLayoutConstraint *infoButtonPositionB;
	__weak IBOutlet NSLayoutConstraint *manualButtonPositionA;
	__weak IBOutlet NSLayoutConstraint *manualButtonPositionB;
	__weak IBOutlet NSLayoutConstraint *healthButtonPositionA;
	__weak IBOutlet NSLayoutConstraint *healthButtonPositionB;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    noWeightData = YES;
    noSexData = YES;
    
    if (![[HealthKitManager sharedInstance] isHealthAvailable]){
        [self setSecondaryConstraints];
    }
	
	
}

-(void)setSecondaryConstraints{
    [infoButtonPositionA setPriority:1];
    [manualButtonPositionA setPriority:1];
    [healthButtonPositionA setPriority:1];
    
    [infoButtonPositionB setPriority:1000];
    [manualButtonPositionB setPriority:1000];
    [healthButtonPositionB setPriority:1000];
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
    UIAlertController *enterWeight = [UIAlertController alertControllerWithTitle:@"Enter Weight"
                                                                         message:nil
                                                                  preferredStyle:UIAlertControllerStyleAlert];
    [enterWeight addTextFieldWithConfigurationHandler:^(UITextField *textField){
        [textField setKeyboardType:UIKeyboardTypeDecimalPad];
    }];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                    style:UIAlertActionStyleCancel
                                                  handler:nil]];
    [enterWeight addAction:[UIAlertAction actionWithTitle:@"Done"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      if (![[[enterWeight textFields][0] text] isEqualToString:@""]){
                                                          NSString *string = [[enterWeight textFields][0] text];
                                                          NSNumberFormatter * formatter = [NSNumberFormatter new];
                                                          
                                                          NSNumber *num = [formatter numberFromString:string];
                                                          
                                                          if (num != nil){
                                                              weight = [[enterWeight textFields][0] text].doubleValue;
                                                              
                                                              [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                                                                      forKey:[StoredDataManager weightKey]];
                                                              
                                                              if (noSexData){
                                                                  [self getSexManually];
                                                              } else {
                                                                  [self finishCollectingData];
                                                              }
                                                          } else {
                                                              [enterWeight setMessage:@"Enter a valid weight, containing numbers and decimals only"];
                                                              [self presentViewController:enterWeight
                                                                                 animated:YES
                                                                               completion:nil];
                                                          }
                                                          
                                                      } else {
                                                          [self presentViewController:enterWeight
                                                                             animated:YES
                                                                           completion:nil];
                                                      }
                                                  }]];
    [self presentViewController:enterWeight
                       animated:YES
                     completion:nil];
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
                                           [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:sex]
                                                                                                   forKey:[StoredDataManager sexKey]];
                                           [self finishCollectingData];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:self.useManualButton];
}

- (IBAction)handleHealthPressed:(id)sender {
    [[StoredDataManager sharedInstance] userRequestsHealth];
    
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
            } else {
                noWeightData = NO;
            }
            if (userSex == nil || [userSex biologicalSex] == HKBiologicalSexNotSet) {
                noSexData = YES;
            } else {
                noSexData = NO;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (noWeightData){
                    [self showNoWeightDataAlert];
                } else {
                    weight = [[[results firstObject] quantity] doubleValueForUnit:[HKUnit poundUnit]];
                    [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithDouble:weight]
                                                                            forKey:[StoredDataManager weightKey]];
                    if (noSexData){
                        [self getSexManually];
                    } else {
                        [[StoredDataManager sharedInstance] updateDictionaryWithObject:[NSNumber numberWithInteger:[userSex biologicalSex]]
                                                                                forKey:[StoredDataManager sexKey]];
                        [self finishCollectingData];
                    }
                }
            });
        }
    }];
}

-(void)showNoWeightDataAlert{
    
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
}

-(void)finishCollectingData{
    UIAlertController *important = [UIAlertController alertControllerWithTitle:@"Important Message"
                                                                       message:@"Drink Keeper can estimate blood alcohol content given information about your body and what you've had to drink. This is not a definitive reading, and should not be taken as infallible. Never drink and drive."
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [important addAction:[UIAlertAction actionWithTitle:@"Understood"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *action){
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"finishSetup"
                                                                                                        object:nil];
                                                    if ([(AppDelegate *)[UIApplication sharedApplication].delegate watchAppNeedsSync]) {
                                                        [[StoredDataManager sharedInstance] updateWatchContext];
                                                    }
                                                    [self.navigationController dismissViewControllerAnimated:YES
                                                                                                  completion:^(void){
                                                                                                      //TODO Notifications
                                                                                                      //[(AppDelegate *)[UIApplication sharedApplication].delegate registerNotifications];
                                                                                                  }];
                                                }]];
    [self presentViewController:important
                       animated:YES
                     completion:nil];
}

@end
