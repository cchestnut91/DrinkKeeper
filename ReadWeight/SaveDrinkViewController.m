//
//  SaveDrinkViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "SaveDrinkViewController.h"
#import "AppDelegate.h"

@interface SaveDrinkViewController ()

@end

@implementation SaveDrinkViewController {
    HKHealthStore *healthStore;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)pressSkip:(id)sender {
    UIAlertController *confirm = [UIAlertController alertControllerWithTitle:@"Are you sure?" message:@"You will not be able to keep track of BAC over time" preferredStyle:UIAlertControllerStyleAlert];
    [confirm addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [confirm addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
        [self moveOn];
    }]];
    [self presentViewController:confirm animated:YES completion:nil];
}

- (IBAction)pressHealth:(id)sender {
    [healthStore requestAuthorizationToShareTypes:[NSSet setWithObject:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodAlcoholContent]] readTypes:nil completion:^(BOOL success, NSError *error){
        [self moveOn];
    }];
}

-(void)moveOn{
    UIAlertController *notice = [UIAlertController alertControllerWithTitle:@"Important Message" message:@"This app is for entertainment purposes only. Given the info about you and what you've had to drink, it estimates blood alcohol content. This is not a definitive reading, and should not be taken as infallible. Never drink and drive." preferredStyle:UIAlertControllerStyleAlert];
    [notice addAction:[UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self.navigationController dismissViewControllerAnimated:true completion:nil];
    }]];
    [self presentViewController:notice animated:YES completion:nil];
}
@end
