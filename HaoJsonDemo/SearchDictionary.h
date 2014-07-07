//
//  SearchDictionary.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/7/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Food.h"
@interface SearchDictionary : NSObject

@property (nonatomic, retain) NSMutableDictionary *dict;

+ (SearchDictionary *)sharedInstance;

+ (SearchDictionary *)initSharedInstance;

+ (void)addSearchHistory:(Food*) food;

+ (void)removeAllSearchHistory;

+(void)saveSearchHistoryToLocalDB;

@end
