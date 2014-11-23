//
//  InterfaceController.m
//  ReadWeight WatchKit Extension
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "InterfaceController.h"
#import "AddDrinkContext.h"


@interface InterfaceController()

@end


@implementation InterfaceController{
    double bac;
}

- (instancetype)initWithContext:(id)context {
    self = [super initWithContext:context];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateBACLabel)
                                                     name:@"updatedHealthValues"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(finishSetup)
                                                     name:@"finishSetup"
                                                   object:nil];
        [self setupView];
        
    }
    return self;
}

-(void)setupView{
    
    if ([[StoredDataManager sharedInstance] needsSetup]){
        [self.setupGroup setHidden:NO];
        [self.defaultGroup setHidden:YES];
    } else {
        [self.setupGroup setHidden:YES];
        [self.defaultGroup setHidden:NO];
    }
    
    bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
}

-(void)finishSetup{
    NSLog(@"finished");
    [self setupView];
}

-(void)updateBACLabel{
    bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
    [self setupView];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
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
@end



