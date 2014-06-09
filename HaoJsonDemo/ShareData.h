//
//  ShareData.h
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import <Foundation/Foundation.h>

/*******************************************************/
/*       Add Desired Dict Table names in .m file       */
/*                                                     */
/*  Change Lang/Keyword file name in .m file in ARRAY  */
/*                                                     */
/* Change Filterwords file name in .m file as PROPERTY */
/*******************************************************/

typedef NS_ENUM(NSInteger, TargetLang){
    Chinese = 1,
    English = 2
};

@interface ShareData : NSObject
+(instancetype)shareData;

//File names
-(NSString *) keywordFileName;
-(NSString *) langFileName:(TargetLang) lang;
-(NSString *) langTableName:(TargetLang) lang;
-(NSString *) filterWordsFileName;

//Read-only file path
-(NSString *) readonlyKeywordFilePath;
-(NSString *) readonlyLangFilePath:(TargetLang) lang;
-(NSString *) readonlyFilterWordsFilePath;
-(NSString *) readonlyPathByFileName:(NSString *)filename;

//Writable copy path
//Writable copies not exist initially
-(NSString *) writableKeywordFilePath;
-(NSString *) writableLangFilePath:(TargetLang) lang;
-(NSString *) writableFilterWordsFilePath;
-(NSString *) writablePathByFileName:(NSString *) filename;
@end
