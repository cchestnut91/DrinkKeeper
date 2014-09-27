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
    double mult;
    NSDate *drinkTime;
    NSArray *sizeOptions;
    NSTimeInterval offset;
}

- (IBAction)pressCancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.multButton addTarget:self action:@selector(pressMult:) forControlEvents:UIControlEventTouchUpInside];
    [self.timeButton addTarget:self action:@selector(pressTime:) forControlEvents:UIControlEventTouchUpInside];
    offset = 0;
    
    if ([self.type isEqualToString:@"Liquor"]){
        [self.quantLabel setText:@"Strength"];
        sizeOptions = @[@"Weak (0.5 - 1 Shot)", @"Normal (1 Shot)", @"Strong (> 1 Shot)", @"Woah! (Woah!)"];
        mult = 1;
    } else if ([self.type isEqualToString:@"Wine"]){
        [self.quantLabel setText:@"Glass Size"];
        sizeOptions = @[@"Small", @"Normal", @"Large"];
        mult = 1;
    } else {
        [self.quantLabel setText:@"Beer Size"];
        sizeOptions = @[@"12 oz.", @"16 oz.", @"20 oz."];
        mult = 1.3333;
    }
    [self.multButton setTitle:[sizeOptions objectAtIndex:1] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)pressMult:(id)sender{
    [ActionSheetStringPicker showPickerWithTitle:@"Drink Strength" rows:sizeOptions initialSelection:1 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue){
        [self.multButton setTitle:[sizeOptions objectAtIndex:selectedIndex] forState:UIControlStateNormal];
        if ([self.type isEqualToString:@"Liquor"]){
            mult = (selectedIndex + 1) / 2.0;
        } else if ([self.type isEqualToString:@"Wine"]){
            NSArray *options = @[@0.75, @1, @1.25];
            mult = [options[selectedIndex] doubleValue];
        } else if ([self.type isEqualToString:@"Beer"]){
            NSArray *options = @[@1, @1.333, @1.666];
            mult = [options[selectedIndex] doubleValue];
        }
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    } origin:sender];
}

-(IBAction)pressTime:(id)sender{
    NSMutableArray *timeOptions = [[NSMutableArray alloc] init];
    [timeOptions addObject:@"Now"];
    for (int i = 1; i < 12; i++){
        [timeOptions addObject:[NSString stringWithFormat:@"%d minutes ago", i * 5]];
    }
    [timeOptions addObject:@"1 Hour Ago"];
    
    [ActionSheetStringPicker showPickerWithTitle:@"When?" rows:timeOptions initialSelection:2 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue){
        [self.timeButton setTitle:[timeOptions objectAtIndex:selectedIndex] forState:UIControlStateNormal];
        offset = selectedIndex * 5 * 60;
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    } origin:sender];
}

-(IBAction)pressGo:(id)sender{
    drinkTime = [[NSDate date] dateByAddingTimeInterval:-1 * offset];
    Drink *newDrink = [[Drink alloc] initWithType:self.type andMultiplier:[NSNumber numberWithDouble:mult] andTime:drinkTime];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:newDrink forKey:@"newDrink"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newDrink" object:nil userInfo:userInfo];
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
