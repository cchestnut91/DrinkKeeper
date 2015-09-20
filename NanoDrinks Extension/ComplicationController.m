//
//  ComplicationController.m
//  NanoDrinks Extension
//
//  Created by Calvin Chestnut on 8/28/15.
//  Copyright © 2015 Calvin Chestnut. All rights reserved.
//

#import "ComplicationController.h"

#import "StoredDataManager.h"

@interface ComplicationController ()

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate *date))handler {
    NSDate *start = [[[StoredDataManager sharedInstance] lastSession] startTime];
    if (!start) {
        start = [NSDate date];
    }
    handler([NSDate dateWithTimeIntervalSinceNow:-3600]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate *date))handler {
    handler([NSDate dateWithTimeIntervalSinceNow:43200]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorHideOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry *))handler {
    // Call the handler with the current timeline entry
    BACTimelineItem *item = [[StoredDataManager sharedInstance] getCurrentTimelineEntry];
    
    CLKComplicationTimelineEntry *entry = [self getTimelineEntryForItem:item inComplication:complication];
    
    handler(entry);
}


- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void (^)(NSArray<CLKComplicationTimelineEntry *> * _Nullable))handler {
    // Call the handler with the timeline entries prior to the given date
    NSArray *items = [[StoredDataManager sharedInstance] getTimelineItemsBeforeDate:date withLimit:limit];
    
    NSArray *ret = [NSArray new];
    
    for (BACTimelineItem *item in items) {
        ret = [ret arrayByAddingObject:[self getTimelineEntryForItem:item inComplication:complication]];
    }
    handler(ret);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> *entries))handler {
    // Call the handler with the timeline entries after to the given date
    NSArray *items = [[StoredDataManager sharedInstance] getTimelineItemsAfterDate:date withLimit:limit];
    
    NSArray *ret = [NSArray new];
    
    for (BACTimelineItem *item in items) {
        ret = [ret arrayByAddingObject:[self getTimelineEntryForItem:item inComplication:complication]];
    }
    handler(ret);
}

#pragma mark Update Scheduling

- (void)getNextRequestedUpdateDateWithHandler:(void(^)( NSDate * _Nullable updateDate))handler {
    // Call the handler with the date when you would next like to be given the opportunity to update your complication content
    if ([[StoredDataManager sharedInstance] getCurrentBAC] > 0.0) {
        handler([NSDate dateWithTimeIntervalSinceNow:60]);
    } else {
        handler([NSDate dateWithTimeIntervalSinceNow:300]);
    }
}

#pragma mark - Placeholder Templates

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)( CLKComplicationTemplate * _Nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
    CLKSimpleTextProvider *textProvider = [CLKSimpleTextProvider textProviderWithText:@"BAC"];
    CLKSimpleTextProvider *secondLineTextProvider = [CLKSimpleTextProvider textProviderWithText:@"0.000"];
    CLKSimpleTextProvider *longTextProvider = [CLKSimpleTextProvider textProviderWithText:@"BAC 0.000"];
    CLKImageProvider *imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[self getImageForComplication:complication]];
    UIColor *customRed = [UIColor colorWithRed:229/255.0 green:48/255.0 blue:75/255.0 alpha:1];
    [imageProvider setTintColor:customRed];
    
    NSDictionary *providers = @{@"headerProvider" : textProvider,
                                @"valueProvider" : secondLineTextProvider,
                                @"longTextProvider" : longTextProvider,
                                @"imageProvider" : imageProvider};
    
    handler([self getTemplateForComplication:complication withProviders:providers]);
}

- (CLKComplicationTemplate *)getTemplateForComplication:(CLKComplication *)complication withProviders:(NSDictionary *)providers {
    
    if (complication.family == CLKComplicationFamilyModularSmall) {
        CLKComplicationTemplateModularSmallStackImage *template = [[CLKComplicationTemplateModularSmallStackImage alloc] init];
        template.line1ImageProvider = providers[@"imageProvider"];
        template.line2TextProvider = providers[@"valueProvider"];
        return template;
    } else if (complication.family == CLKComplicationFamilyModularLarge) {
        CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init];
        template.headerTextProvider = providers[@"headerProvider"];
        template.bodyTextProvider = providers[@"valueProvider"];
        return template;
        
    } else if (complication.family == CLKComplicationFamilyCircularSmall) {
        CLKComplicationTemplateCircularSmallStackText *template = [[CLKComplicationTemplateCircularSmallStackText alloc] init];
        template.line1TextProvider = providers[@"headerProvider"];
        template.line2TextProvider = providers[@"valueProvider"];
        return template;
        
    } else if (complication.family == CLKComplicationFamilyUtilitarianSmall) {
        CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
        template.imageProvider = providers[@"imageProvider"];
        template.textProvider = providers[@"valueProvider"];
        return template;
        
    } else if (complication.family == CLKComplicationFamilyUtilitarianLarge) {
        CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
        template.imageProvider = providers[@"imageProvider"];
        template.textProvider = providers[@"longTextProvider"];
        return template;
    }
    
    return nil;
}

- (CLKComplicationTimelineEntry *)getTimelineEntryForItem:(BACTimelineItem *)item inComplication:(CLKComplication *)complication{
    CLKComplicationTimelineEntry *entry = [[CLKComplicationTimelineEntry alloc] init];
    
    if (item) {
        [entry setDate:item.date];
    } else {
        [entry setDate:[NSDate date]];
    }
    
    CLKSimpleTextProvider *textProvider = [CLKSimpleTextProvider textProviderWithText:@"BAC"];
    CLKSimpleTextProvider *secondLineTextProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:@"%.3f", item.bac.doubleValue * 100]];
    CLKSimpleTextProvider *longTextProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:@"BAC %.3f", item.bac.doubleValue * 100]];
    CLKImageProvider *imageProvider = [CLKImageProvider imageProviderWithOnePieceImage:[self getImageForComplication:complication]];
    UIColor *customRed = [UIColor colorWithRed:229/255.0 green:48/255.0 blue:75/255.0 alpha:1];
    [imageProvider setTintColor:customRed];
    
    NSDictionary *providers = @{@"headerProvider" : textProvider,
                                @"valueProvider" : secondLineTextProvider,
                                @"longTextProvider" : longTextProvider,
                                @"imageProvider" : imageProvider};
    
    [entry setComplicationTemplate:[self getTemplateForComplication:complication withProviders:providers]];
    
    return entry;
}

- (UIImage *)getImageForComplication:(CLKComplication *)complication {
    UIImage *ret;
    if (complication.family == CLKComplicationFamilyCircularSmall) {
        ret = [UIImage imageNamed:@"Complication/Circular"];
    } else if (complication.family == CLKComplicationFamilyModularLarge || complication.family == CLKComplicationFamilyModularSmall) {
        ret = [UIImage imageNamed:@"Complication/Modular"];
    } else if (complication.family == CLKComplicationFamilyUtilitarianLarge || complication.family == CLKComplicationFamilyUtilitarianSmall) {
        ret = [UIImage imageNamed:@"Complication/Utilitarian"];
    }
    return ret;
}

@end
