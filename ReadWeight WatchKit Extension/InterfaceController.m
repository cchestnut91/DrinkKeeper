//
//  InterfaceController.m
//  ReadWeight WatchKit Extension
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "InterfaceController.h"
#import "AddDrinkContext.h"

NSString *detailsIdent = @"showDetails";
NSString *hangIdent = @"rateHang";

@interface InterfaceController()

@end


@implementation InterfaceController{
    double bac;
}

- (instancetype)init{
	self = [super init];
	
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
		
	}
	return self;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
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
    
    bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
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
	
	[self updateBACLabel];
}

-(void)updateBACLabel{
    bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
	
	[self updateMenuItems];
}

- (void)updateMenuItems{
	[self clearAllMenuItems];
	if ([[StoredDataManager sharedInstance] currentSession]){
		[self addMenuItemWithItemIcon:WKMenuItemIconMore title:@"Session Details" action:@selector(showSessionDetails)];
		[self addMenuItemWithImageNamed:@"liquorGlassSmall" title:@"Duplicate Drink" action:@selector(addLastDrinkAgain)];
		[self addMenuItemWithImageNamed:@"undoIcon" title:@"Remove Last" action:@selector(removeLastDrink)];
	} else if ([[StoredDataManager sharedInstance] lastSession]){
		[self addMenuItemWithItemIcon:WKMenuItemIconMore title:@"Session Details" action:@selector(showSessionDetails)];
	}
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
    [self clearAllMenuItems];
	[self updateMenuItems];
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

-(void)handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)localNotification{
    DrinkingSession *session = [[localNotification userInfo] objectForKey:@"session"];
    [self handleActionWithIdentifier:identifier
                          forSession:session];
}

-(void)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)remoteNotification{
    NSString *sessionID = [remoteNotification objectForKey:@"sessionID"];
    DrinkingSession *session = [[StoredDataManager sharedInstance] getSessionForID:sessionID];
    if (session){
        [self handleActionWithIdentifier:identifier forSession:session];
    }
}

-(void)handleActionWithIdentifier:(NSString *)identifier forSession:(DrinkingSession *)session{
    if ([identifier isEqualToString:detailsIdent]){
        [self pushControllerWithName:@"sessionDetails" context:session];
    }
}

@end



