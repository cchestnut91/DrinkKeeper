//
//  MainViewController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/29/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "StoredDataManager.h"
#import "HealthKitManager.h"
#import "AddDrinkViewController.h"
#import "DrinkingSession.h"

@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *bacLabel;
@property (weak, nonatomic) IBOutlet UILabel *bacSubHead;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@property (weak, nonatomic) IBOutlet UIView *buttonContainerView;
@property (weak, nonatomic) IBOutlet UILabel *currentSessionLabel;
@property (weak, nonatomic) IBOutlet UIButton *liquorButton;
@property (weak, nonatomic) IBOutlet UIButton *beerButton;
@property (weak, nonatomic) IBOutlet UIButton *wineButton;
- (IBAction)handleLiquorPressed:(id)sender;
- (IBAction)handleBeerPressed:(id)sender;
- (IBAction)handleWinePressed:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *sessionDetailsContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionDetailsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionDetailsVerticalSpace;
@property (weak, nonatomic) IBOutlet UILabel *sessionLengthValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberDrinksTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberDrinksValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *peakTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *peakValueLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *profileButton;

-(void)addDrinkFromURL:(NSNotification *)notification;
-(void)addDrink:(NSNotification *)notification;
-(void)recalcBAC;

@end
