//
//  HealthKitInfoViewController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HealthKitInfoViewController : UIViewController
- (IBAction)handleClosePressed:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end
