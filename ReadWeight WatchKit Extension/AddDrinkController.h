//
//  AddDrinkController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "InterfaceController.h"
#import "AddDrinkContext.h"

@interface AddDrinkController : InterfaceController

@property (strong, nonatomic) AddDrinkContext *drinkContext;

@property (weak, nonatomic) IBOutlet WKInterfaceSlider *threeOptionSlider;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *fourOptionSlider;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *strengthLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *strengthPreviewLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *strengthSlider;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *whenLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *whenPreview;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *whenRelativeLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceSlider *whenSlider;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *addButton;
- (IBAction)sizeValueChanged:(float)value;
- (IBAction)whenValueChanged:(float)value;
- (IBAction)addDrink;

@end
