//
//  MainInterfaceController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/14/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#import "StoredDataManager.h"

@interface MainInterfaceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bacLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *addDrinkLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *beerButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *wineButton;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *liquorButton;
- (IBAction)pressBeer;
- (IBAction)pressWine;
- (IBAction)pressLiquor;

@property (weak, nonatomic) IBOutlet WKInterfaceGroup *defaultGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *setupGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *refreshButton;
- (IBAction)refreshTapped;

@end
