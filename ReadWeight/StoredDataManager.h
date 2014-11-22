//
//  StoredDataManager.h
//  DrinkTracker
//
//  Created by Calvin Chestnut on 11/20/14.
//  Copyright (c) 2014 Calvin Chestnut. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoredDataManager : NSObject

@property (strong, nonatomic) NSString *sessionDirectory;
@property (strong, nonatomic) NSString *healthData;

-(NSString *)applicationDocumentsDirectory;

+(StoredDataManager *)sharedInstance;
+(NSString *)weightKey;
+(NSString *)sexKey;

-(NSDictionary *)healthDictionary;
-(id)getWeight;
-(id)getSex;
-(BOOL)needsSetup;
-(void)updateDictionaryWithObject:(id)objectIn forKey:(NSString *)keyIn;

@end
