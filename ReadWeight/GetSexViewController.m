//
//  GetSexViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "GetSexViewController.h"
#import "AppDelegate.h"
#import "ActionSheetStringPicker.h"

@interface GetSexViewController ()

@end

@implementation GetSexViewController{
    HKHealthStore *healthStore;
    NSInteger sex;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    healthStore = [(AppDelegate *)[UIApplication sharedApplication].delegate healthStore];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pressManual:(id)sender {
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
                                           [JNKeychain saveValue:[NSNumber numberWithInteger:sex] forKey:@"sex"];
                                           [self performSegueWithIdentifier:@"saveDrink" sender:self];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

- (IBAction)pressHealth:(id)sender {
    [healthStore requestAuthorizationToShareTypes:nil readTypes:[NSSet setWithObject:[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex]] completion:^(BOOL success, NSError *error){
        dispatch_async(dispatch_get_main_queue(), ^{
            sex = [[healthStore biologicalSexWithError:nil] biologicalSex];
            HKBiologicalSexObject *sexObject = [healthStore biologicalSexWithError:nil];
            sex = [sexObject biologicalSex];
            if (sex == HKBiologicalSexNotSet){
                UIAlertController *confirmOther = [UIAlertController alertControllerWithTitle:@"Confirm Sex" message:@"Health indicates you identify as 'Other'. Is this correct?" preferredStyle:UIAlertControllerStyleAlert];
                [confirmOther addAction:[UIAlertAction actionWithTitle:@"Change" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self pressManual:sender];
                    });
                }]];
                [confirmOther addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    // Move on
                    [JNKeychain saveValue:[NSNumber numberWithInteger:sex] forKey:@"sex"];
                    [self performSegueWithIdentifier:@"saveDrink" sender:self];
                }]];
                [self presentViewController:confirmOther animated:YES completion:nil];
            } else {
                // Move on
                [JNKeychain saveValue:[NSNumber numberWithInteger:sex] forKey:@"sex"];
                [self performSegueWithIdentifier:@"saveDrink" sender:self];
            }
        });
        
    }];
}
@end
