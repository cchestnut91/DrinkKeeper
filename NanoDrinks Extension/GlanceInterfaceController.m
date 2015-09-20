//
//  GlanceInterfaceController.m
//  DrinkTracker
//
//  Created by Calvin Chestnut on 9/19/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "GlanceInterfaceController.h"

#import "StoredDataManager.h"

@interface GlanceInterfaceController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation GlanceInterfaceController

- (instancetype)init {
    self = [super init];
    if (self){
        // Initialize variables here.
        // Configure interface objects here.
        NSLog(@"%@ initWithContext", self);
        
    }
    return self;
}

- (void)awakeWithContext:(id)context{
    [super awakeWithContext:context];
    if ([[StoredDataManager sharedInstance] needsSetup]){
        [self.bacGroup setHidden:YES];
        [self.setupGroup setHidden:NO];
    } else {
        [self.bacGroup setHidden:NO];
        [self.setupGroup setHidden:YES];
    }
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reloadBac:) userInfo:nil repeats:YES];
}

- (void)willActivate {
    [super willActivate];
    // This method is called when watch view controller is about to be visible to user
    double bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
}

- (void)reloadBac:(NSTimer *)timer {
    double bac = [[StoredDataManager sharedInstance] getCurrentBAC];
    [self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
}

- (void)didDeactivate {
    [super didDeactivate];
    // This method is called when watch view controller is no longer visible
}

@end



