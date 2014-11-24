//
//  NotificationController.h
//  ReadWeight WatchKit Extension
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface NotificationController : WKUserNotificationInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *titleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *sessionInfoGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *durationTitleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *drinksTitleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *peakTitleLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *durationLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *drinksLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *peakLabel;

@end
