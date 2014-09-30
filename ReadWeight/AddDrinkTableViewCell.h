//
//  AddDrinkTableViewCell.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/29/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddDrinkTableViewCell : UITableViewCell

-(void)setType:(NSString *)type;
@property (weak, nonatomic) IBOutlet UIImageView *drinkIcon;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
