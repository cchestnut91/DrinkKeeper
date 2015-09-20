//
//  GlanceInterfaceController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/19/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface GlanceInterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bacLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *bacGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *setupGroup;

@end
