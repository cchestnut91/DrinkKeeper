//
//  MainTableViewController.m
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "MainTableViewController.h"
#import "StoredDataManager.h"
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
        [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
        
        [self.tableView reloadData];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    
    [super viewWillDisappear:animated];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([[StoredDataManager sharedInstance] currentSession]){
        return 3;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1){
        return 3;
    } else if (section == 2){
        return 3;
    }
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1){
        return @"Add a drink";
    } else if (section == 2){
        return @"Current Drinking Session";
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        return 91;
    } else if (indexPath.section == 1){
        return 50;
    }
    return tableView.rowHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        BACLabelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bacCell"];
        
        self.bacLabel = [[cell contentView] subviews][1];
        [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
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
    } else if (indexPath.section == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoDetailCell"];
        if (indexPath.row == 0){
            [[cell textLabel] setText:@"Session Length"];
            NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:[[[StoredDataManager sharedInstance] currentSession] startTime]];
            int numMinutes = time / 60.0;
            int numHours = numMinutes / 60;
            
            numMinutes = numMinutes - (numHours * 60);
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%d:%d", numHours, numMinutes]];
        } else if (indexPath.row == 1){
            [[cell textLabel] setText:@"Number of Drinks"];
            
            [[cell detailTextLabel] setText:[NSString stringWithFormat:@"%@", [[[StoredDataManager sharedInstance] currentSession] totalDrinks]]];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"seeDetailsCell"];
            [[cell textLabel] setText:@"See More Details"];
        }
        
        return cell;
    }
    return nil;
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
// TODO Add Details ViewController and perform segue
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"addDrink"]){
        [(AddDrinkViewController *)segue.destinationViewController setType:typePressed];
    }
}


@end
