//
//  NewDrinkInterfaceController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/16/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

#import "AddDrinkContext.h"

@interface NewDrinkInterfaceController : WKInterfaceController

@property (strong, nonatomic) AddDrinkContext *drinkContext;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *strengthLabel;

@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *strengthPicker;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfacePicker *timePicker;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceButton *addDrinkButton;

- (IBAction)addDrinkPressed;

@end
