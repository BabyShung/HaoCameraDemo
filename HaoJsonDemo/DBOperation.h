//
//  DBOperation.h
//  TestDB
//
//  Created by MEI C on 6/2/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ShareData.h"
#import "Food.h"

/*******************************/
/*!!!!DEFINED IN SHARE DATA!!!!*/
/* Keyword table name: Keyword */
/*                             */
/*   Lang table name: Chinese  */
/*                             */
/*  Dict table name: ToChinese */
/*******************************/
@interface DBOperation : NSObject

-(void) executeSingleSQL:(NSString *)sql;

-(void) createKeywordTable;

-(void) createLangTable:(TargetLang) lang;

-(void) createSearchHistoryTable;



/*******************************/
/*!!!!    Search History   !!!!*/
/*   1. upsertSearchHistory    */
/*                             */
/*    */
/*                             */
/*  */
/*******************************/
-(void) upsertSearchHistory:(Food *)food;

-(NSMutableArray *)fetchSearchHistoryByOrder_withLimitNumber:(NSUInteger)number;

//Found keywords will be saved in kwArray
-(NSMutableArray *) searchWords:(NSArray *) wordsArray getKeywords:(NSMutableArray *)kwArray inLangTable:(TargetLang)lang;

//For Dictionary update
//Download files from server
//-(void) downloadFileByFileName:(NSString *)filename;

@end
