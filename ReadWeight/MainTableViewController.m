//
//  MainTableViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "MainTableViewController.h"
#import "StoredDataManager.h"
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "AddDrinkViewController.h"
#import "BACLabelTableViewCell.h"
#import "AddDrinkTableViewCell.h"
#import "Drink.h"

@interface MainTableViewController ()

@end

@implementation MainTableViewController
{
    NSString *typePressed;
    double bac;
    BOOL showUber;
    DrinkingSession *currentSession;
    NSTimer *timer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

-(void)addDrinkFromURL:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    typePressed = [userInfo objectForKey:@"type"];
    [self performSegueWithIdentifier:@"addDrink"
                              sender:self];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ([[StoredDataManager sharedInstance] needsSetup]){
        [self performSegueWithIdentifier:@"getWeight"
                                  sender:self];
    } else {
        
        [[HealthKitManager sharedInstance] updateHealthValues];
        
        bac = [[StoredDataManager sharedInstance] getCurrentBAC];
        
        showUber = NO;
        
        currentSession = [[StoredDataManager sharedInstance] currentSession];
        [[HealthKitManager sharedInstance] updateHealthValues];
        
        bac = [[StoredDataManager sharedInstance] getCurrentBAC];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:30
                                                 target:self
                                               selector:@selector(recalcBAC)
                                               userInfo:nil
                                                repeats:YES];
        [timer fire];
        [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac]];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    
    [super viewWillDisappear:animated];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (showUber && !showUber){
        return 3;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        return 3;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return @"Add a drink";
    } else if (section == 2){
        return @"Need a ride home?";
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 91;
    } else if (indexPath.section == 1){
        return 50;
    } else {
        return 90;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        BACLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bacCell"];
        
        self.bacLabel = [[cell contentView] subviews][1];
        [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac]];
        return cell;
    } else if (indexPath.section == 1) {
        AddDrinkTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drinkCell"];
        if (indexPath.row == 0){
            [cell setType:@"Beer"];
        } else if (indexPath.row == 1){
            [cell setType:@"Wine"];
        } else {
            [cell setType:@"Liquor"];
        }
        return cell;
    } else {
        return [tableView dequeueReusableCellWithIdentifier:@"uberCell"];
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

-(void)recalcBAC{
    [[HealthKitManager sharedInstance] updateHealthValues];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    if (indexPath.section == 1){
        NSArray *types = @[@"Beer", @"Wine", @"Liquor"];
        typePressed = types[indexPath.row];
        [self performSegueWithIdentifier:@"addDrink"
                                  sender:self];
    } else if (indexPath.section == 2){
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]){
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"uber://?action=setPickup&pickup=my_location"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://m.uber.com"]];
        }
    };
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addDrink"]){
        [(AddDrinkViewController *)segue.destinationViewController setType:typePressed];
    }
}


@end
