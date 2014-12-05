//
//  MainViewController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/29/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController {
    double bac;
    NSTimer *timer;
    BOOL needsSetup;
    BOOL hasCurrentSession;
    BOOL hasRecentSession;
}

#pragma mark UISetup

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setTitle:@"Drink Keeper"];
    [[self profileButton] setTitle:@"Profile"];
    
    [self.view bringSubviewToFront:self.sessionDetailsContainerView];
    
    [[self.navigationController navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    
    [self maskButtons];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addDrink:)
                                                 name:@"newDrink"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addDrinkFromURL:)
                                                 name:@"addFromURL"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"checkLaunchURL"
                                                        object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
// setup labels
    
    if (![[StoredDataManager sharedInstance] needsSetup]){
        
        needsSetup = NO;
        
        [self.bacLabel setHidden:NO];
        
        bac = [[StoredDataManager sharedInstance] getCurrentBAC];
        [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
        
        [self.sessionLengthValueLabel setHidden:NO];
        
        DrinkingSession *session = [[StoredDataManager sharedInstance] lastSession];
        
        if (!session){
            
            hasCurrentSession = NO;
            
            [self.sessionLengthValueLabel setText:@"No Sessions"];
        } else {
            
            [self updateSessionSectionWithSection:session];
            
        }
        
        [self.bacSubHead setHidden:NO];
        [self.bacSubHead setText:@"Current B.A.C"];
    } else {
        needsSetup = YES;
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
// setup gesture recognizers and timer
    
    if (needsSetup){
        [self performSegueWithIdentifier:@"getWeight"
                                  sender:self];
    } else {
        
        [[HealthKitManager sharedInstance] updateHealthValues];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:30
                                                 target:self
                                               selector:@selector(recalcBAC)
                                               userInfo:nil
                                                repeats:YES];
        
        [timer fire];
        
        if (hasCurrentSession){
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideView)];
            [self.sessionDetailsContainerView addGestureRecognizer:tapGesture];
            
            UITapGestureRecognizer *blurTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideView)];
            [self.blurView addGestureRecognizer:blurTap];
            
        }
    }
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    
    [super viewWillDisappear:animated];
}

-(void)maskButtons{
    [[self.liquorButton layer] setCornerRadius:40];
    [[self.beerButton layer] setCornerRadius:40];
    [[self.wineButton layer] setCornerRadius:40];
}

-(void)updateSessionSectionWithSection:(DrinkingSession *)session{
    
    [self updateSessionLengthLabelWithSession:session];
    
    [self.numberDrinksTitleLabel setText:@"Number of Drinks"];
    [self.numberDrinksValueLabel setText:[NSString stringWithFormat:@"%@", [session totalDrinks]]];
    
    [self.peakTitleLabel setText:@"Peak B.A.C."];
    [self.peakValueLabel setText:[NSString stringWithFormat:@"%.3f", [[session peakValue] floatValue] * 100]];
    
    
    [self.currentSessionLabel setHidden:NO];
    if ([[StoredDataManager sharedInstance] currentSession]){
        [self.currentSessionLabel setText:@"Current Session"];
    } else {
        [self.currentSessionLabel setText:@"Last Session"];
    }
    
    hasCurrentSession = YES;
}

-(void)updateSessionLengthLabelWithSession:(DrinkingSession *)session{
    
    NSTimeInterval time;
    
    if ([session endTime]){
        time = [[session endTime] timeIntervalSinceDate:[session startTime]];
    } else {
        time = [[NSDate date] timeIntervalSinceDate:[session startTime]];
    }
    
    int numMinutes = time / 60.0;
    int numHours = numMinutes / 60;
    
    if (numHours > 0){
        
        numMinutes = numMinutes - (numHours * 60);
        
        if (numMinutes > 9){
            [self.sessionLengthValueLabel setText:[NSString stringWithFormat:@"%d:%d Hours", numHours, numMinutes]];
        } else {
            [self.sessionLengthValueLabel setText:[NSString stringWithFormat:@"%d:0%d Hours", numHours, numMinutes]];
        }
        
    } else {
        
        [self.sessionLengthValueLabel setText:[NSString stringWithFormat:@"%d Minutes", numMinutes]];
        
    }
}

#pragma mark data managers

-(void)recalcBAC{
    [[HealthKitManager sharedInstance] updateHealthValues];
    bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
    
    DrinkingSession *session = [[StoredDataManager sharedInstance] lastSession];
    
    if (session){
        [self updateSessionLengthLabelWithSession:session];
    }
}

-(void)addDrink:(NSNotification *)notification{
    
    NSDictionary *userInfo = [notification userInfo];
    
    Drink *newDrink = [userInfo objectForKey:@"newDrink"];
    
    [[StoredDataManager sharedInstance] addDrinkToCurrentSession:newDrink];
    [self recalcBAC];
    
// TODO If we have other notifications, only cancel the one that needs to be canceled.
    // NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    UILocalNotification *sober = [[UILocalNotification alloc] init];
    
    // TODO why is this 0.015? Should be metabolism constant?
    double secondsLeft = (bac / 0.015) * 60 * 60;
    
    [sober setFireDate:[NSDate dateWithTimeIntervalSinceNow:secondsLeft]];
    [sober setAlertBody:@"BAC has reached zero"];
    [sober setSoundName:UILocalNotificationDefaultSoundName];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:sober];
}

-(void)addDrinkFromURL:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSString *typePressed = [userInfo objectForKey:@"type"];
    [self performSegueWithIdentifier:@"addDrink" sender:typePressed];
}

#pragma mark IBActions

-(void)slideView{
    
    if (self.sessionDetailsVerticalSpace.constant == 0){
        self.sessionDetailsVerticalSpace.constant = (self.sessionDetailsHeight.constant - 100) * -1;
        
    } else {
        self.sessionDetailsVerticalSpace.constant = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.blurView.hidden){
            [self.blurView setHidden:NO];
            [self.blurView setAlpha:1];
        } else {
            [self.blurView setAlpha:0];
        }
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        if ([self.blurView alpha] == 0 && self.blurView.hidden == NO){
            [self.blurView setHidden:YES];
        }
    }];
}

- (IBAction)handleLiquorPressed:(id)sender {
    [self performSegueWithIdentifier:@"addDrink" sender:sender];
}
- (IBAction)handleBeerPressed:(id)sender {
    [self performSegueWithIdentifier:@"addDrink" sender:sender];
}
- (IBAction)handleWinePressed:(id)sender {
    [self performSegueWithIdentifier:@"addDrink" sender:sender];
}

#pragma mark ViewController Overrides

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"addDrink"]){
        if ([[self.navigationController viewControllers] count] > 1){
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
        NSString *typePressed;
        
        if ([sender isKindOfClass:[NSString class]]){
            typePressed = sender;
        } else if ([sender tag] == 0){
            typePressed = @"Liquor";
        } else if ([sender tag] == 1){
            typePressed = @"Beer";
        } else if ([sender tag] == 2){
            typePressed = @"Wine";
        }
        
        [(AddDrinkViewController *)segue.destinationViewController setType:typePressed];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
