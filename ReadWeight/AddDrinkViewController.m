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

@property (strong, nonatomic) NSUserActivity *activity;

@end

@implementation AddDrinkViewController{
    NSTimeInterval offset;
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
    
    self.selectedSizeIndex = 0;
    
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
    
    if (self.type) {
        self.drinkContext = [[AddDrinkContext alloc] initWithType:self.type];
    } else if (self.drinkContext) {
        self.type = self.drinkContext.type;
    }
    
    if ([self.type isEqualToString:@"Liquor"]){
        [self.multTitle setText:@"Strength"];
    } else if ([self.type isEqualToString:@"Wine"]){
        [self.multTitle setText:@"Glass Size"];
    } else {
        [self.multTitle setText:@"Beer Size"];
    }
    
    [self.multLabel setText:[self.drinkContext titleForSize:[[UserPreferences sharedInstance] prefersMetric]]];
    
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"com.calvinchestnut.activity-adding-drink"];
    [activity setTitle:[NSString stringWithFormat:@"Adding %@", self.type]];
    NSData *drinkContextData = [NSKeyedArchiver archivedDataWithRootObject:self.drinkContext];
    [activity setUserInfo:@{@"drinkContext" : drinkContextData}];
    self.activity = activity;
    self.activity.delegate = self;
    [self.activity becomeCurrent];
    
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
    NSArray *suggestions = [self.drinkContext suggestionStrings:[[UserPreferences sharedInstance] prefersMetric]];
    
    [ActionSheetStringPicker showPickerWithTitle:@"Drink Strength"
                                            rows:suggestions
                                initialSelection:self.selectedSizeIndex
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue){
                                           if (selectedIndex == [suggestions count] - 1) {
                                               NSMeasurementFormatter *mf = [[NSMeasurementFormatter alloc] init];
                                               NSString *preferred = [[UserPreferences sharedInstance] prefersMetric] ? [mf stringFromUnit:[NSUnitVolume milliliters]] : [mf stringFromUnit:[NSUnitVolume fluidOunces]];
                                               UIAlertController *sizeEntry = [UIAlertController alertControllerWithTitle:@"Enter Size"
                                                                                                                  message:[NSString stringWithFormat:@"Please enter the size of your drink in %@", preferred]
                                                                                                           preferredStyle:UIAlertControllerStyleAlert];
                                               [sizeEntry addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                                                             style:UIAlertActionStyleCancel
                                                                                           handler:nil]];
                                               [sizeEntry addAction:[UIAlertAction actionWithTitle:@"Confirm"
                                                                                             style:UIAlertActionStyleDefault
                                                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                                                               NSString *selected = [[[sizeEntry textFields] firstObject] text];
                                                                                               if ([selected doubleValue]) {
                                                                                                   self.selectedSizeIndex = selectedIndex;
                                                                                                   double value = [selected doubleValue];
                                                                                                   NSUnit *unit = [[UserPreferences sharedInstance] prefersMetric] ? [NSUnitVolume milliliters] : [NSUnitVolume fluidOunces];
                                                                                                   NSMeasurement *newSize = [[NSMeasurement alloc] initWithDoubleValue:value
                                                                                               unit:unit];
                                                                                                   [self.drinkContext setSize:newSize];
                                                                                                   [self.multLabel setText:[self.drinkContext titleForSize:[[UserPreferences sharedInstance] prefersMetric]]];
                                                                                               } else {
                                                                                                   UIAlertController *invalid = [UIAlertController alertControllerWithTitle:@"Invalid Value"
                                                                                                                                                                    message:@"Please enter a valid, non-zero number value"
                                                                                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                                                                                                   [invalid addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                                                                                               style:UIAlertActionStyleDefault
                                                                                                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                                                                                                 [self presentViewController:sizeEntry
                                                                                                                                                                    animated:YES
                                                                                                                                                                  completion:nil];
                                                                                                                                             }]];
                                                                                                    [self presentViewController:invalid
                                                                                                                       animated:YES
                                                                                                                     completion:nil];
                                                                                               }
                                                                                           }]];
                                               [sizeEntry addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                                                   textField.placeholder = @"Drink size";
                                                   textField.keyboardType = UIKeyboardTypeNumberPad;
                                               }];
                                               [self presentViewController:sizeEntry
                                                                  animated:YES
                                                                completion:nil];
                                               
                                           } else {
                                               self.selectedSizeIndex = selectedIndex;
                                               [self.drinkContext setSize:[self.drinkContext suggestions][selectedIndex]];
                                               
                                               [self.multLabel setText:[self.drinkContext titleForSize:[[UserPreferences sharedInstance] prefersMetric]]];
                                           }
                                           
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
                                           [self.drinkContext setTime:[NSDate dateWithTimeIntervalSinceNow:-1 * offset]];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         NSLog(@"Block Picker Canceled");
                                     }
                                          origin:sender];
}

-(IBAction)pressGo:(id)sender{
    Drink *newDrink = [[Drink alloc] initWithDrinkContext:self.drinkContext];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:newDrink
                                                         forKey:@"newDrink"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newDrink"
                                                        object:nil
                                                      userInfo:userInfo];
    [self.activity invalidate];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)pressUnitButton:(id)sender {
    BOOL prefersMetric = NO;
    if (![[(UIBarButtonItem *)sender title] isEqualToString:@"oz."]) {
        prefersMetric = YES;
    }
    
    [[UserPreferences sharedInstance] setPrefersMetric:prefersMetric];
    
    [self.multLabel setText:[self.drinkContext titleForSize:[[UserPreferences sharedInstance] prefersMetric]]];
    [self.unitButton setTitle:[[UserPreferences sharedInstance] prefersMetric] ? @"oz." : @"ml"];
}

- (void)updateUserActivityState:(NSUserActivity *)activity
{
    NSData *drinkContextData = [NSKeyedArchiver archivedDataWithRootObject:self.drinkContext];
    activity.userInfo = @{@"drinkContext" : drinkContextData};
}

- (void)userActivityWillSave:(NSUserActivity *)userActivity
{
    NSData *drinkContextData = [NSKeyedArchiver archivedDataWithRootObject:self.drinkContext];
    userActivity.userInfo = @{@"drinkContext" : drinkContextData};
}

@end
