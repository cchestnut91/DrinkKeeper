//
//  TransLoadingIndicator.m
//  RevCheckIn
//
//  This class creates and updates a loading indicator, visually similar to standard iOS indicators.
//
//  Created by Calvin Chestnut on 8/27/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "TransLoadingIndicator.h"

@implementation TransLoadingIndicator


/*
  Initialization method performs general set up with given frame
*/
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    [self setUp];
    
    return self;
}

/*
  Initializes UI ELements and Blur effects with default theme.
  Hides unneeded elements
*/
-(void)setUp{
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];;
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.bounds];
    [self addSubview:blurEffectView];
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.bounds];
    
    // Initializes Label and Indicator for default
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 108, 150, 42)];
    [self.textLabel setText:@"Label"];
    [self.textLabel setTextAlignment:NSTextAlignmentCenter];
    [self.textLabel setNumberOfLines:2];
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(56, 56, 37, 37)];
    [self.indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    // Initializes imageview and sets to hide
    
    self.image = [[UIImageView alloc] initWithFrame:self.indicator.frame];
    [self.image setHidden:YES];
    [self.image setContentMode:UIViewContentModeScaleAspectFit];
    [self.image setClipsToBounds:YES];
    [self.image setBackgroundColor:[UIColor clearColor]];
    
    // Add elements to the vibrancy view
    [[vibrancyEffectView contentView] addSubview:self.textLabel];
    [[vibrancyEffectView contentView] addSubview:self.indicator];
    [[vibrancyEffectView contentView] addSubview:self.image];
    
    // Add the vibrancy view to the blur view
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
    
    // Rounded rectangles are better than regular rectangles
    [self.layer setCornerRadius:25];
    
    // Don't bleed over
    [self setClipsToBounds:YES];
    
}

/*
  Recreate the vibrancy effect with default settings with the light theme
*/
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

/*
 Recreate the vibrancy effect with default settings with the extra light theme
 */
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

/*
 Recreate the vibrancy effect with default settings with the dark theme
 */
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

/*
  Show success message and check mark
*/
-(void)succeed{
    [self.textLabel setText:@"Success!"];
    [self.indicator setHidden:YES];
    [self.image setHidden:NO];
    [self.image setImage:[UIImage imageNamed:@"finish"]];
    [self fadeAway];
}

/*
  Show Failed message and x
*/
-(void)fail{
    [self.textLabel setText:@"Failed"];
    [self.indicator setHidden:YES];
    [self.image setHidden:NO];
    [self.image setImage:[UIImage imageNamed:@"fail"]];
    [self fadeAway];
}

/*
  Create delay to read the result message and fade the view to hidden
*/
-(void)fadeAway{
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(animate) userInfo:nil repeats:NO];
}

/*
  Animate the view into a hidden state
  Hide elements when finished
*/
-(void)animate{
    [self setHidden:NO];
    [UIView animateWithDuration:1 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished){
        [self hide];
        [self setOpaque:YES];
    }];
}

/*
  Update indicator label text
*/
-(void)changeText:(NSString *)textIn{
    [self.textLabel setText:textIn];
}

/*
  Unhides the view and starts loading indicator animation
*/
-(void)startAnimating{
    if (self.hidden){
        [self setHidden:NO];
    }
    [self.indicator setHidden:NO];
    [self.image setHidden:YES];
    [self.indicator startAnimating];
}

/*
  Stops loadingIndicator animation
*/
-(void)stopAnimating{
    [self.indicator stopAnimating];
}

/*
  Immediately hides the loading view
*/
-(void)hide{
    [self stopAnimating];
    [self setHidden:YES];
}

@end
