//
//  TransLoadingIndicator.m
//  RevCheckIn
//
//  Created by Calvin Chestnut on 8/27/14.
//  Copyright (c) 2014 Andrew Sowers. All rights reserved.
//

#import "TransLoadingIndicator.h"

@implementation TransLoadingIndicator {
    
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    [self setUp];
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    
    [self setUp];
    
    return self;
}

-(void)setLightStyle{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];;
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.bounds];
    [self addSubview:blurEffectView];
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.bounds];
    
    // Add label to the vibrancy view
    [[vibrancyEffectView contentView] addSubview:self.textLabel];
    [[vibrancyEffectView contentView] addSubview:self.indicator];
    
    // Add the vibrancy view to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

-(void)setExtraLightStyle{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];;
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.bounds];
    [self addSubview:blurEffectView];
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.bounds];
    
    // Add label to the vibrancy view
    [[vibrancyEffectView contentView] addSubview:self.textLabel];
    [[vibrancyEffectView contentView] addSubview:self.indicator];
    
    // Add the vibrancy view to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

-(void)setDarkStyle{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];;
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.bounds];
    [self addSubview:blurEffectView];
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.bounds];
    
    // Add label to the vibrancy view
    [[vibrancyEffectView contentView] addSubview:self.textLabel];
    [[vibrancyEffectView contentView] addSubview:self.indicator];
    
    // Add the vibrancy view to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
}

-(void)setUp{
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];;
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.bounds];
    [self addSubview:blurEffectView];
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.bounds];
    
    //Shoudl send subview to back?
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, 150, 42)];
    [self.textLabel setText:@"Label"];
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.textLabel setNumberOfLines:2];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(56, 56, 37, 37)];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    self.image = [[UIImageView alloc] initWithFrame:self.indicator.frame];
    [self.image setHidden:YES];
    [self.image setContentMode:UIViewContentModeScaleAspectFit];
    [self.image setClipsToBounds:YES];
    [self.image setBackgroundColor:[UIColor clearColor]];
    
    // Add label to the vibrancy view
    [[vibrancyEffectView contentView] addSubview:self.textLabel];
    [[vibrancyEffectView contentView] addSubview:self.indicator];
    [[vibrancyEffectView contentView] addSubview:self.image];
    
    // Add the vibrancy view to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
    
    [self.layer setCornerRadius:25];
    [self setClipsToBounds:YES];
    
}

-(void)succeed{
    [self.textLabel setText:@"Success!"];
    [self.indicator setHidden:YES];
    [self.image setHidden:NO];
    [self.image setImage:[UIImage imageNamed:@"finish"]];
    [self fadeAway];
}

-(void)fail{
    [self.textLabel setText:@"Failed"];
    [self.indicator setHidden:YES];
    [self.image setHidden:NO];
    [self.image setImage:[UIImage imageNamed:@"fail"]];
    [self fadeAway];
}

-(void)fadeAway{
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(animate)
                                   userInfo:nil
                                    repeats:NO];
}

-(void)animate{
    [self setHidden:NO];
    [UIView animateWithDuration:1
                     animations:^{
                         [self setAlpha:0];
                     } completion:^(BOOL finished){
                         [self hide];
                         [self setOpaque:YES];
                     }];
}

-(void)changeText:(NSString *)textIn{
    [self.textLabel setText:textIn];
}

-(void)startAnimating{
    if (self.hidden){
        [self setHidden:NO];
    }
    [self.indicator setHidden:NO];
    [self.image setHidden:YES];
    [self.indicator startAnimating];
}

-(void)stopAnimating{
    [self.indicator stopAnimating];
}

-(void)hide{
    [self stopAnimating];
    [self setHidden:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
