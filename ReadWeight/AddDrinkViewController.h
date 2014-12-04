//
//  AddDrinkViewController.h
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/26/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddDrinkContext.h"
#import "StoredDataManager.h"
#import "ActionSheetStringPicker.h"

@interface AddDrinkViewController : UIViewController

@property NSString *type;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *multButton;
-(IBAction)pressMult:(id)sender;
-(IBAction)pressGo:(id)sender;
-(IBAction)pressTime:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *multLabel;
@property (weak, nonatomic) IBOutlet UILabel *multTitle;
@property (weak, nonatomic) IBOutlet UILabel *timeTitle;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
