//
//  ANDExampleViewController.h
//  SimpleAnimatedGraph v.0.1.0
//
//  Created by Andrzej Naglik on 19.01.2014.
//  Copyright (c) 2014 Andrzej Naglik. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANDInternalLineChartViewDelegate <NSObject>
@required

- (void)didStartReloadingChart;
- (void)didFinishReloadingChart;

@end

@class ANDLineChartView;

@interface ANDInternalLineChartView : UIView

@property (weak, nonatomic) id<ANDInternalLineChartViewDelegate> delegate;

@property (nonatomic, weak) ANDLineChartView *chartContainer;

@property (nonatomic, readonly, strong) UIImage *circleImage;

// Support for constraint-based layout (auto layout)
// If nonzero, this is used when determining -intrinsicContentSize
@property(nonatomic, assign) CGFloat preferredMinLayoutWidth;


- (instancetype)initWithFrame:(CGRect)frame chartContainer:(ANDLineChartView*)chartContainer;
- (void)reloadData;
@end
