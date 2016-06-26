//
//  NewDrinkInterfaceController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/16/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "NewDrinkInterfaceController.h"

#import "UserPreferences.h"
#import "Drink.h"
#import "StoredDataManager.h"
#import "HealthKitManager.h"

@interface NewDrinkInterfaceController ()

@property (strong, nonatomic) NSDateFormatter *formatter;
@property (strong, nonatomic) NSUserActivity *activity;

@end

@implementation NewDrinkInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"h:mm a"];
    [self setTitle:@""];
    
    self.drinkContext = (AddDrinkContext *)context;
    if (self.drinkContext.title){
        [self setTitle:self.drinkContext.title];
    }
    
    if (![[self.drinkContext type] isEqualToString:@"Liquor"]){
        [self.strengthLabel setText:@"Size"];
    }
    
    NSMutableArray *strengthPickerItems = [NSMutableArray new];
    NSArray *optionLabels = [self.drinkContext suggestionStringsDefaultOnly:[[UserPreferences sharedInstance] prefersMetric]];
    for (NSString *strength in optionLabels) {
        WKPickerItem *item = [[WKPickerItem alloc] init];
        [item setTitle:strength];
        
        [strengthPickerItems addObject:item];
    }
    
    [self.strengthPicker setItems:strengthPickerItems];
    
    if (![[self.drinkContext type] isEqualToString:@"Beer"]) {
        [self.strengthPicker setSelectedItemIndex:1];
    }
    
    NSMutableArray *contentItems = [NSMutableArray new];
    for (int i = 1; i < 100; i++) {
        NSString *label = [NSString stringWithFormat:@"%.2f%%", i/100.0];
        WKPickerItem *item = [[WKPickerItem alloc] init];
        [item setTitle:label];
        [contentItems addObject:item];
    }
    [self.contentPicker setItems:contentItems];
    int selected = (int)(self.drinkContext.standardContent * 100);
    [self.contentPicker setSelectedItemIndex:selected];
    
    NSMutableArray *whenPickerItems = [NSMutableArray new];
    for (int i = 12; i > 0; i--) {
        NSString *label = [NSString stringWithFormat:@"%d min. ago", i  * 5];
        WKPickerItem *item = [[WKPickerItem alloc] init];
        [item setTitle:label];
        [whenPickerItems addObject:item];
    }
    
    NSString *label = @"Now";
    WKPickerItem *item = [[WKPickerItem alloc] init];
    [item setTitle:label];
    [whenPickerItems addObject:item];
    
    [self.timePicker setItems:whenPickerItems];
    [self.timePicker setSelectedItemIndex:whenPickerItems.count - 1];
    
    [self updateMenuItem];
    
    NSUserActivity *activity = [[NSUserActivity alloc] initWithActivityType:@"com.calvinchestnut.activity-adding-drink"];
    [activity setTitle:[NSString stringWithFormat:@"Adding %@", self.drinkContext.type]];
    NSData *drinkContextData = [NSKeyedArchiver archivedDataWithRootObject:self.drinkContext];
    [activity setUserInfo:@{@"drinkContext" : drinkContextData}];
    self.activity = activity;
    self.activity.delegate = self;
    [self.activity becomeCurrent];
}

- (void)updateMenuItem {
    [self clearAllMenuItems];
    BOOL prefMetric = [[UserPreferences sharedInstance] prefersMetric];
    [self addMenuItemWithImage:[UIImage imageNamed:prefMetric ? @"ozUnit" : @"mlUnit"] title:@"Change Units" action:@selector(changeUnits)];
}

- (IBAction)changeUnits {
    BOOL prevPref = [[UserPreferences sharedInstance] prefersMetric];
    
    [[UserPreferences sharedInstance] setPrefersMetric:!prevPref];
    
    NSMutableArray *strengthPickerItems = [NSMutableArray new];
    NSArray *optionLabels = [self.drinkContext suggestionStringsDefaultOnly:[[UserPreferences sharedInstance] prefersMetric]];
    for (NSString *strength in optionLabels) {
        WKPickerItem *item = [[WKPickerItem alloc] init];
        [item setTitle:strength];
        
        [strengthPickerItems addObject:item];
    }
    
    [self.strengthPicker setItems:strengthPickerItems];
    
    [self updateMenuItem];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (IBAction)strengthChanged:(NSInteger)value {
    [self.drinkContext setSize:[[self.drinkContext suggestions] objectAtIndex:value]];
}

- (IBAction)timeChanged:(NSInteger)value {
    int mult = 13 - value - 1;
    int secondsAgo = 5 * 60 * mult;
    
    [self.drinkContext setTime:[NSDate dateWithTimeIntervalSinceNow:-1 * secondsAgo]];
}

- (IBAction)contentChanged:(NSInteger)value {
    double contentValue = value / 100.0;
    [self.drinkContext setContent:contentValue];
}

- (IBAction)addDrinkPressed {
    Drink *newDrink = [[Drink alloc] initWithDrinkContext:self.drinkContext];
    
    [[StoredDataManager sharedInstance] addDrinkToCurrentSession:newDrink];
    [_activity invalidate];
    [self popToRootController];
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



