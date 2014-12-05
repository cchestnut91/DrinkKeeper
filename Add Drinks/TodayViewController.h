//
//  TodayViewController.h
//  Add Drinks
//
//  Created by Calvin Chestnut on 9/27/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NotificationCenter/NotificationCenter.h>
#import <HealthKit/HealthKit.h>
#import "StoredDataManager.h"
#import "JNKeychain.h"

@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *bacLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentLabel;
- (IBAction)addBeer:(id)sender;
- (IBAction)addWine:(id)sender;
- (IBAction)addLiquor:(id)sender;

@end
