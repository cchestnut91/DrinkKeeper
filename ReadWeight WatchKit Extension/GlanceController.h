//
//  GlanceController.h
//  ReadWeight WatchKit Extension
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface GlanceController : WKInterfaceController
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *bacLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *bacGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *setupGroup;

@end
