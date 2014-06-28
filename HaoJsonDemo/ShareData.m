//
//  ShareData.m
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import "ShareData.h"

@interface ShareData()
{
    NSArray *langFileNames;
    NSArray *dbLangTableNames;
}
@property (strong, retain) NSArray *dbFileNames;
@property (strong, retain) NSArray *dbLangTableNames;
@property (strong, retain) NSString *filterwordsFileName;
@end

@implementation ShareData

@synthesize dbFileNames;
@synthesize dbLangTableNames;
@synthesize filterwordsFileName;


+(instancetype)shareData{
    static ShareData *sharedata = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedata = [[self alloc] init];
    });
    return sharedata;
}

-(instancetype) init
{
    if (self = [super init]) {
        self.dbFileNames = @[@"foodlist_a-z_sql_KW.txt", @"foodlist_a-z_sql_CN.txt"];
        self.dbLangTableNames = @[@"Chinese"];
        self.filterwordsFileName = @"filterwords.txt";
    }
    return self;
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
@end
