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
#import "DrinkingSession.h"

@interface StoredDataManager : NSObject

@property (strong, nonatomic) NSString *sessionDirectory;
@property (strong, nonatomic) NSString *healthData;

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
-(void)addDrinkToCurrentSession:(Drink *)drinkIn;
-(void)updateDictionaryWithObject:(id)objectIn forKey:(NSString *)keyIn;
-(double)genderStandard;
-(double)metabolismConstant;
-(double)getCurrentBAC;

@end
