//
//  TodayViewController.h
//  Add Drinks
//
//  Created by Calvin Chestnut on 9/27/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodayViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *bacLabel;
- (IBAction)addBeer:(id)sender;
- (IBAction)addWine:(id)sender;
- (IBAction)addLiquor:(id)sender;

@end