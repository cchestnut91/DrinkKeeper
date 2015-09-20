//
//  StoredDataManager.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <HealthKit/HealthKit.h>

#import "AppWatchConnectionManager.h"
#import "DrinkingSession.h"
#import "UserPreferences.h"

@interface StoredDataManager : NSObject

@property (strong, nonatomic) NSString *sessionDirectory;
@property (strong, nonatomic) NSString *healthData;
@property (strong, nonatomic) NSMutableDictionary *savedSessions;

-(NSString *)applicationDocumentsDirectory;

+(StoredDataManager *)sharedInstance;
+(NSString *)weightKey;
+(NSString *)sexKey;

-(void)duplicateLastDrink;
-(NSDictionary *)healthDictionary;
-(id)getWeight;
-(id)getSex;
-(BOOL)needsSetup;
-(DrinkingSession *)lastSession;
-(DrinkingSession *)currentSession;
-(DrinkingSession *)getSessionForID:(NSString *)sessionID;
-(void)saveDrinkingSession:(DrinkingSession *)session;
-(void)removeDrinkingSession:(DrinkingSession *)session;
-(void)addDrinkToCurrentSession:(Drink *)drinkIn;
-(void)removeLastDrink;
-(void)updateDictionaryWithObject:(id)objectIn forKey:(NSString *)keyIn;
-(double)genderStandard;
-(double)metabolismConstant;
-(double)getCurrentBAC;
-(void)userRequestsHealth;
-(BOOL)userHasRequestedHealth;
-(void)handleMessage:(NSDictionary *)message;
-(void)handleContext:(NSDictionary *)context;
- (NSArray *)pastSessions;
- (void)updateWatchContext;
- (void)updateUserPreferenceContext;
- (void)updateSavedSessionContextWithContext:(NSDictionary *)dict;
- (NSDictionary *)watchContext;
- (void)updateLastSessionContext;
- (void)markSessionSaved:(DrinkingSession *)session withValues:(NSArray *)values;

- (BACTimelineItem *)getCurrentTimelineEntry;
- (NSArray *)getTimelineItemsBeforeDate:(NSDate *)date withLimit:(NSUInteger)limit;
- (NSArray *)getTimelineItemsAfterDate:(NSDate *)date withLimit:(NSUInteger)limit;

@end
