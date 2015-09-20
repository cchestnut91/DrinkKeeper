//
//  SessionDetailsViewController.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/13/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrinkingSession.h"
#import "ANDLineChartView.h"

@interface SessionDetailsViewController : UIViewController <ANDLineChartViewDataSource, ANDLineChartViewDelegate>

@property (strong, nonatomic) DrinkingSession *session;

@property (weak, nonatomic) IBOutlet UILabel *mainSessionHeader;
@property (weak, nonatomic) IBOutlet UILabel *numDrinksLabel;
@property (weak, nonatomic) IBOutlet UILabel *numDrinksValue;

@property (weak, nonatomic) IBOutlet UIView *numLiquorView;
@property (weak, nonatomic) IBOutlet UILabel *nulLiquorLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLIquorValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numLiquorHeight;

@property (weak, nonatomic) IBOutlet UIView *numBeerView;
@property (weak, nonatomic) IBOutlet UILabel *numBeerLabel;
@property (weak, nonatomic) IBOutlet UILabel *numBeerValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numBeerHeight;

@property (weak, nonatomic) IBOutlet UIView *peakBACView;
@property (weak, nonatomic) IBOutlet UILabel *peakBACLabel;
@property (weak, nonatomic) IBOutlet UILabel *peakBACValue;

@property (weak, nonatomic) IBOutlet UIView *numWineView;
@property (weak, nonatomic) IBOutlet UILabel *numWineLabel;
@property (weak, nonatomic) IBOutlet UILabel *numWineValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *numWineHeight;

@property (weak, nonatomic) IBOutlet ANDLineChartView *lineChartView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *chartLoadingView;

@end
