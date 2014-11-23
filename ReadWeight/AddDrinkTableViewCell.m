//
//  AddDrinkTableViewCell.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/29/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "AddDrinkTableViewCell.h"

@implementation AddDrinkTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected
              animated:animated];

    // Configure the view for the selected state
}

-(void)setType:(NSString *)type{
    [self.label setText:type];
    if ([type isEqualToString:@"Beer"]){
        [self.drinkIcon setImage:[UIImage imageNamed:@"beerGlassSmall"]];
    } else if ([type isEqualToString:@"Wine"]){
        [self.drinkIcon setImage:[UIImage imageNamed:@"wineSmall"]];
    } else {
        [self.drinkIcon setImage:[UIImage imageNamed:@"liquorGlassSmall"]];
    }
}

@end
