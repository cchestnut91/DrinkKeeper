//
//  GetWeightViewController.h
//  ReadWeight
//
//  Created by Calvin Chestnut on 9/25/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransLoadingIndicator.h"

@interface UseHealthKitViewController : UIViewController
- (IBAction)pressManual:(id)sender;
- (IBAction)pressHealth:(id)sender;
@property (retain, nonatomic) IBOutlet TransLoadingIndicator *indicator;


@end
