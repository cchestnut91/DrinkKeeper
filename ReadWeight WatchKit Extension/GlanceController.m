//
//  GlanceController.m
//  ReadWeight WatchKit Extension
//
//  Created by Calvin Chestnut on 11/23/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import "GlanceController.h"
#import "StoredDataManager.h"

@interface GlanceController()

@property (strong, nonatomic) NSTimer *timer;

@end


@implementation GlanceController

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
    // This method is called when watch view controller is about to be visible to user
    NSLog(@"%@ will activate", self);
	[self.timer fire];
}

- (void)reloadBac:(NSTimer *)timer {
	double bac = [[StoredDataManager sharedInstance] getCurrentBAC];
	[self.bacLabel setText:[NSString stringWithFormat:@"%.3f", bac * 100]];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    NSLog(@"%@ did deactivate", self);
	[self.timer invalidate];
}

@end



