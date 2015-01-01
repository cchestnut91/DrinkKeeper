//
//  MainInterfaceController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/14/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "MainInterfaceController.h"

#import "AddDrinkContext.h"
#import "HealthKitManager.h"

NSString *detailsIdent = @"showDetails";
NSString *hangIdent = @"rateHang";

@interface MainInterfaceController ()

    @property double bac;

@end

@implementation MainInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateBACLabel)
                                                 name:@"contextReloaded"
                                               object:nil];
    [self updateMenuItems];
    [self setupView];
}

-(void)setupView{
    
    if ([[StoredDataManager sharedInstance] needsSetup]){
        [self.setupGroup setHidden:NO];
        [self.defaultGroup setHidden:YES];
    } else {
        [self.setupGroup setHidden:YES];
        [self.defaultGroup setHidden:NO];
    }
    
    if ([[StoredDataManager sharedInstance] lastSession]){
        
    }
    
    self.bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", self.bac * 100]];
}

-(void)finishSetup{
    NSLog(@"finished");
    [self setupView];
}

-(IBAction)showSessionDetails{
    [self pushControllerWithName:@"sessionDetails" context:[[StoredDataManager sharedInstance] lastSession]];
}

-(IBAction)addLastDrinkAgain{
    [[StoredDataManager sharedInstance] duplicateLastDrink];
    
    [self updateBACLabel];
}

- (void)removeLastDrink {
    [[StoredDataManager sharedInstance] removeLastDrink];
    DrinkingSession *session = [[StoredDataManager sharedInstance] lastSession];
    if ([[[[StoredDataManager sharedInstance] lastSession] drinks] count] == 0) {
        [[StoredDataManager sharedInstance] removeDrinkingSession:[[StoredDataManager sharedInstance] lastSession]];
    }
    [self updateBACLabel];
}

-(void)updateBACLabel{
    self.bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", self.bac * 100]];
    
    [self updateMenuItems];
}

- (void)updateMenuItems{
    [self clearAllMenuItems];
    if ([[StoredDataManager sharedInstance] currentSession]){
        [self addMenuItemWithItemIcon:WKMenuItemIconMore title:@"Session Details" action:@selector(showSessionDetails)];
        Drink *lastDrink = [[[[StoredDataManager sharedInstance] currentSession] drinks] lastObject];
        NSString *dupImage;
        if ([lastDrink.type isEqualToString:@"Beer"]) {
            dupImage = @"beerGlassSmall";
        } else if ([lastDrink.type isEqualToString:@"Wine"]) {
            dupImage = @"wineSmall";
        } else {
            dupImage = @"liquorGlassSmall";
        }
        [self addMenuItemWithImageNamed:dupImage title:@"Duplicate Drink" action:@selector(addLastDrinkAgain)];
        [self addMenuItemWithImageNamed:@"undoIcon" title:@"Remove Last" action:@selector(removeLastDrink)];
    } else if ([[StoredDataManager sharedInstance] lastSession]){
        [self addMenuItemWithItemIcon:WKMenuItemIconMore title:@"Session Details" action:@selector(showSessionDetails)];
    }
}

- (IBAction)pressBeer {
    AddDrinkContext *context = [[AddDrinkContext alloc] initWithType:[AddDrinkContext beerType]];
    
    [self pushControllerWithName:@"Add Drink"
                         context:context];
}

- (IBAction)pressWine {
    AddDrinkContext *context = [[AddDrinkContext alloc] initWithType:[AddDrinkContext wineType]];
    
    [self pushControllerWithName:@"Add Drink"
                         context:context];
}

- (IBAction)pressLiquor {
    AddDrinkContext *context = [[AddDrinkContext alloc] initWithType:[AddDrinkContext liquorType]];
    
    [self pushControllerWithName:@"Add Drink"
                         context:context];
}
- (IBAction)refreshTapped {
    [self setupView];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



