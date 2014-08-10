//
//  ShareData.m
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import "ShareData.h"

@interface ShareData()

@property (strong, retain) NSArray *dbFileNames;
@property (strong, retain) NSArray *dbLangTableNames;
@property (strong, retain) NSString *filterwordsFileName;
@property (nonatomic,readwrite) TargetLang defaultTargetLang;
@end

@implementation ShareData

static ShareData *_shareData = nil;



+(ShareData *)shareData{
    
    return _shareData;
}

+(ShareData *) shareDataSetUp
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _shareData = [[ShareData alloc] init];
        _shareData.dbFileNames = @[@"basic_foods_2894_en.txt", @"basic_foods_2894_zh.txt"];
        _shareData.dbLangTableNames = @[@"Chinese",@"Keyword"];
        _shareData.filterwordsFileName = @"filterwords.txt";
        _shareData.defaultTargetLang =Chinese;
        
    });
    return _shareData;
    
}

//File names
-(NSString *) keywordFileName
{
    return [self.dbFileNames objectAtIndex:0];
}

-(NSString *) langFileName:(TargetLang) lang
{
    return [self.dbFileNames objectAtIndex:lang];
}

-(NSString *) langTableName:(TargetLang) lang
{
    return [self.dbLangTableNames objectAtIndex:(lang-1)];
}

-(NSString *) filterWordsFileName
{
    return self.filterwordsFileName;
}

//Read Only files path - in main bunble

-(NSString *) readonlyKeywordFilePath
{
    return [self readonlyPathByFileName:[self keywordFileName]];
}

-(NSString *) readonlyLangFilePath:(TargetLang) lang
{
    return [self readonlyPathByFileName:[self langFileName:lang]];
}

-(NSString *) readonlyFilterWordsFilePath
{
    return [self readonlyPathByFileName:[self filterwordsFileName]];
}

-(NSString *) readonlyPathByFileName:(NSString *)filename
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:filename];
    return path;
}

//Writable files path
-(NSString *) writableKeywordFilePath
{
    return [self writablePathByFileName:[self keywordFileName]];
}

-(NSString *) writableLangFilePath:(TargetLang) lang
{
    return [self writablePathByFileName:[self langFileName:lang]];
}


-(NSString *) writableFilterWordsFilePath
{
    return [self writablePathByFileName:[self filterwordsFileName]];
}

-(NSString *) writablePathByFileName:(NSString *) filename{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:filename];
    return path;
}

//User Settings
-(void) setDefaultTargetLangTo:(TargetLang )lang
{
    self.defaultTargetLang = lang;
}
@end
