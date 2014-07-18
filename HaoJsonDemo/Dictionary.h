//
//  Dictionary.h
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareData.h"

@interface Dictionary : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic,readonly) TargetLang translateTo;

@property (strong,nonatomic) NSArray *terms;

@property (strong,nonatomic) NSMutableArray *results;

@property (nonatomic,readonly,getter = isSearchingFood) BOOL searchingFood;

-(instancetype) initDictInDefaultLang;

-(instancetype) initDictInLang:(TargetLang) lang;

//Search locally, return foods
-(NSArray *) localSearchOCRString:(NSString *)inputStr;

//-(NSArray *) lookupOCRString:(NSString *)inputStr foundKeywords:(NSMutableArray *)keywords;

//Send search request to server
-(void) serverSearchOCRString:(NSString *)inputStr andCompletion:(void (^)(NSArray *results, BOOL success))block;

//Search locally, match the input string at the beginning
-(NSArray *) localBlurSearchString:(NSString *)typeStr;

//Dictionary update function
//  1. download file from server;
//  2. create table.
//+(void)updateKeyword;
//+(void)updateDictInLang:(TargetLang) lang;

//-(NSArray *)splitAndFilterWordsFromString:(NSString *)str;

@end
