//
//  UITestViewController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/28/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "UITestViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface UITestViewController ()
@property (weak, nonatomic) IBOutlet UIButton *buttonView;
@property (weak, nonatomic) IBOutlet UIButton *buttonTwo;
@property (weak, nonatomic) IBOutlet UIButton *buttonThree;
@property (weak, nonatomic) IBOutlet UIView *slidingView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slidingTopConstraint;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;

@end

@implementation UITestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_buttonView.layer setCornerRadius:40];
    [_buttonThree.layer setCornerRadius:40];
    [_buttonTwo.layer setCornerRadius:40];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideView)];
    [_slidingView addGestureRecognizer:tapGesture];
    UITapGestureRecognizer *blueTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(slideView)];
    [_blurView addGestureRecognizer:blueTap];
}

-(void)slideView{
    
    if (_slidingTopConstraint.constant == 0){
        _slidingTopConstraint.constant = -200;
        
    } else {
        _slidingTopConstraint.constant = 0;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        if (self.blurView.hidden){
            [self.blurView setHidden:NO];
            [self.blurView setAlpha:1];
        } else {
            [self.blurView setAlpha:0];
        }
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished){
        if ([self.blurView alpha] == 0 && self.blurView.hidden == NO){
            [self.blurView setHidden:YES];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
