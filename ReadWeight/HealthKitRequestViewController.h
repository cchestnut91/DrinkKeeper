//
//  HealthKitRequestViewController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/19/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransLoadingIndicator.h"

@interface HealthKitRequestViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *healthImage;
@property (weak, nonatomic) IBOutlet TransLoadingIndicator *loadingView;
@property (weak, nonatomic) IBOutlet UIButton *useManualButton;
@property (weak, nonatomic) IBOutlet UIButton *useHealthButton;
- (IBAction)handleManualPressed:(id)sender;
- (IBAction)handleHealthPressed:(id)sender;


@end
