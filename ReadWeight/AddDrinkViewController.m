//
//  AddDrinkViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AddDrinkViewController.h"

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
    // Do any additional setup after loading the view.
    [self.multButton addTarget:self
                        action:@selector(pressMult:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.timeButton addTarget:self
                        action:@selector(pressTime:)
              forControlEvents:UIControlEventTouchUpInside];
    offset = 0;
    
    drinkContext = [[AddDrinkContext alloc] initWithType:self.type];
    
    if ([self.type isEqualToString:@"Liquor"]){
        [self.quantLabel setText:@"Strength"];
    } else if ([self.type isEqualToString:@"Wine"]){
        [self.quantLabel setText:@"Glass Size"];
    } else {
        [self.quantLabel setText:@"Beer Size"];
    }
    [self.multButton setTitle:[drinkContext titleForMult]
                     forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressMult:(id)sender{
    [ActionSheetStringPicker showPickerWithTitle:@"Drink Strength"
                                            rows:[drinkContext optionLabels]
                                initialSelection:[drinkContext selectedIndex]
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue){
                                           [drinkContext setSelectedMult:[NSNumber numberWithInteger:selectedIndex]];
                                           [drinkContext setSelectedIndex:selectedIndex];
                                           
                                           [self.multButton setTitle:[[drinkContext optionLabels] objectAtIndex:drinkContext.selectedMult.intValue]
                                                            forState:UIControlStateNormal];
                                           
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
                                           [self.timeButton setTitle:[timeOptions objectAtIndex:selectedIndex] forState:UIControlStateNormal];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
