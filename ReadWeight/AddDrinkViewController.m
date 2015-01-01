//
//  AddDrinkViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AddDrinkViewController.h"
#import <QuartzCore/QuartzCore.h>

#import "UserPreferences.h"

@interface AddDrinkViewController ()

@end

@implementation AddDrinkViewController{
    NSTimeInterval offset;
    AddDrinkContext *drinkContext;
}

- (IBAction)pressCancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]
                                initWithTitle:@"Back"
                                style:UIBarButtonItemStylePlain
                                target:self
                                action:nil];
    self.navigationController.navigationBar.topItem.backBarButtonItem=btnBack;
    
    [self.unitButton setTitle:[[UserPreferences sharedInstance] prefersMetric] ? @"oz." : @"ml"];
    
    [self setTitle:[NSString stringWithFormat:@"Add %@", self.type]];
    
    [self updateStaticLabels];
    
    // Do any additional setup after loading the view.
    [self.multButton addTarget:self
                        action:@selector(pressMult:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.timeButton addTarget:self
                        action:@selector(pressTime:)
              forControlEvents:UIControlEventTouchUpInside];
    offset = 0;
    
    [self.multButton.layer setCornerRadius:40];
    [self.timeButton.layer setCornerRadius:40];
    [self.doneButton.layer setCornerRadius:40];
    
    drinkContext = [[AddDrinkContext alloc] initWithType:self.type];
    
    if ([self.type isEqualToString:@"Liquor"]){
        [self.multTitle setText:@"Strength"];
    } else if ([self.type isEqualToString:@"Wine"]){
        [self.multTitle setText:@"Glass Size"];
    } else {
        [self.multTitle setText:@"Beer Size"];
    }
    
    [self.multLabel setText:[drinkContext titleForMult:[[UserPreferences sharedInstance] prefersMetric]]];
}

-(void)updateStaticLabels{
    [self.timeTitle setText:@"When"];
    [self.timeLabel setText:@"Now"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressMult:(id)sender{
    [ActionSheetStringPicker showPickerWithTitle:@"Drink Strength"
                                            rows:[[UserPreferences sharedInstance] prefersMetric] ? [drinkContext metricLabels] : [drinkContext optionLabels]
                                initialSelection:[drinkContext selectedIndex]
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue){
                                           [drinkContext setSelectedMult:[[drinkContext strengthOptions] objectAtIndex:selectedIndex]];
                                           [drinkContext setSelectedIndex:selectedIndex];
                                           
                                           [self.multLabel setText:[drinkContext titleForMult:[[UserPreferences sharedInstance] prefersMetric]]];
                                           
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                           NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

-(IBAction)pressTime:(id)sender{
    NSMutableArray *timeOptions = [[NSMutableArray alloc] init];
    [timeOptions addObject:@"Now"];
    for (int i = 1; i < 12; i++){
        [timeOptions addObject:[NSString stringWithFormat:@"%d minutes ago", i * 5]];
    }
    [timeOptions addObject:@"1 Hour Ago"];
    
    [ActionSheetStringPicker showPickerWithTitle:@"When?"
                                            rows:timeOptions
                                initialSelection:2
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue){
                                           [self.timeLabel setText:[timeOptions objectAtIndex:selectedIndex]];
                                           offset = selectedIndex * 5 * 60;
                                           [drinkContext setTime:[[NSDate date] dateByAddingTimeInterval:-1 * offset]];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

-(IBAction)pressGo:(id)sender{
    Drink *newDrink = [[Drink alloc] initWithDrinkContext:drinkContext];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:newDrink
                                                         forKey:@"newDrink"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newDrink"
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)pressUnitButton:(id)sender {
    BOOL prefersMetric = NO;
    if (![[(UIBarButtonItem *)sender title] isEqualToString:@"oz."]) {
        prefersMetric = YES;
    }
    
    [[UserPreferences sharedInstance] setPrefersMetric:prefersMetric];
    
    [self.multLabel setText:[drinkContext titleForMult:[[UserPreferences sharedInstance] prefersMetric]]];
    [self.unitButton setTitle:[[UserPreferences sharedInstance] prefersMetric] ? @"oz." : @"ml"];
}

@end
