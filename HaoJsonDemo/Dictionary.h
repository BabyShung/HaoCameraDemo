//
//  Dictionary.h
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareData.h"

@interface Dictionary : NSObject
@property (nonatomic,readonly) TargetLang translateTo;
@property (strong,nonatomic) NSArray *terms;
@property (strong,nonatomic) NSMutableArray *results;


-(instancetype) initDictInLang:(TargetLang) lang;
-(NSArray *) lookupOCRString:(NSString *)inputStr foundKeywords:(NSMutableArray *)keywords;

//Dictionary update function
//  1. download file from server;
//  2. create table.
//+(void)updateKeyword;
//+(void)updateDictInLang:(TargetLang) lang;

@end
