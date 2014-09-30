//
//  ProfileViewController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/28/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
- (IBAction)pressWeight:(id)sender;
- (IBAction)pressSex:(id)sender;
- (IBAction)close:(id)sender;

@end
