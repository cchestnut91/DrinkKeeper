//
//  SessionDetailsController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import "DrinkingSession.h"

@interface SessionDetailsController : WKInterfaceController

@property (strong, nonatomic) DrinkingSession *session;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *startedGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *startedTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *startedValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *endedGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *endedTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *endedValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *totalGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *totalTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *totalValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *beersGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *beersTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *beersValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *wineGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *wineTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *wineValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *drinksGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *drinksTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *drinksValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *peakGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *peakTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *peakValue;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *hangoverGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *hangoverTitle;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *hangoverValue;

@end
