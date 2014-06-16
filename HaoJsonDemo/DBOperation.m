//
//  DBOperation.m
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import "DBOperation.h"
#import "SQLConnector.h"

@interface DBOperation()

@property (nonatomic) SQLConnector *connector;

@end

@implementation DBOperation

//Set up connection to local databse
-(instancetype) init
{
	if ((self=[super init]) )
    {
        self.connector= [SQLConnector sharedInstance];
	}
	return self;
}

-(void) executeSingleSQL:(NSString *)sql{
    [self.connector openDB];
    NSLog(@"Execute SQL:%@",sql);
    [self execute:sql];
    [self.connector closeDB];
    NSLog(@"SQL executed successfully");
}

-(void) createKeywordTable{
    
    //Get keywords from keyword file
    ShareData *sharedata = [ShareData shareData];
    NSArray *kwArray = [self getItemsInFileByFilePath:[sharedata writableKeywordFilePath]];
    
    [self.connector openDB];
    
    //Create keyword table, drop if it exists;
    [self execute:@"DROP TABLE IF EXISTS Keyword;"];
    [self execute:@"CREATE TABLE Keyword(kwid INTEGER PRIMARY KEY, kwstr TEXT);"];
    
    if (kwArray.count > 0) {
        
        NSString *insert = [NSString stringWithFormat:@"INSERT INTO Keyword(kwstr)VALUES(?);"];
        
        //Insert keywords into table
        [self bulkTextInsertBySQL:insert andArray:kwArray];
        
        [self.connector closeDB];
        
    }
    else{
        
        [self.connector closeDB];
        [self throwDBOperationExceptionCausedBy:@"Empty keyword file"];
    
    }
}

-(void) createLangTable:(TargetLang) lang{
    
    ShareData *sharedata = [ShareData shareData];
    NSString *langTableName = [sharedata langTableName:lang];
    
    [self.connector openDB];
    
    //Get words from Language file
    NSArray *wArray = [self getItemsInFileByFilePath:[sharedata writableLangFilePath:lang]];
    //Create keyword table, drop if it exists;
    [self execute:[NSString stringWithFormat:@"DROP TABLE IF EXISTS %@;",langTableName]];
    [self execute:[NSString stringWithFormat:@"CREATE TABLE %@ (wid INTEGER PRIMARY KEY, wstr TEXT);",langTableName]];
    
    if (wArray.count > 0) {
        
        NSString *insert = [NSString stringWithFormat:@"INSERT INTO %@(wstr)VALUES(?);",langTableName];
        
        //Insert keywords into table
        [self bulkTextInsertBySQL:insert andArray:wArray];
        [self.connector closeDB];
        
    }
    else{
        [self.connector closeDB];
        [self throwDBOperationExceptionCausedBy:[NSString stringWithFormat:@"Empty %@ Language file",langTableName]];
        
    }

}


-(NSMutableArray *) searchWords:(NSArray *)wordsArray getKeywords:(NSMutableArray *)kwArray inLangTable:(TargetLang)lang{
    ShareData *sharedata = [ShareData shareData];
    NSMutableArray *translations = [[NSMutableArray alloc]init];
    
    NSString *langTableName =[sharedata langTableName:lang];
    [self.connector openDB];
    for (NSString *word in wordsArray) {
        NSString *sql =[NSString stringWithFormat:@"SELECT DISTINCT Keyword.kwstr,%@.wstr FROM %@,Keyword WHERE UPPER(Keyword.kwstr)=UPPER('%@') AND Keyword.kwid=%@.wid;",langTableName,langTableName,word,langTableName];
    
        sqlite3_stmt *stmt = nil;
        
        //Prepare the statement
        if (sqlite3_prepare_v2([self.connector database], [sql UTF8String], -1, &stmt, nil) != SQLITE_OK){
            [self.connector closeDB];
            NSString *reason = [NSString stringWithFormat:@"!Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([self.connector database])];
            [self throwDBOperationExceptionCausedBy:reason];
        
        }
        else {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                    char *tmpkword = (char*)sqlite3_column_text(stmt,0);
                    char *tmptrans = (char*)sqlite3_column_text(stmt,1);
                    [kwArray addObject:[NSString stringWithUTF8String:tmpkword]];
                    [translations addObject:[NSString stringWithUTF8String:tmptrans]];
            }
            sqlite3_finalize(stmt);
        }
        
    }
    [self.connector closeDB];
    return translations;
}

-(NSArray *) getItemsInFileByFilePath:(NSString *) path{
    
    NSString *content=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *kwArray = [content componentsSeparatedByString:@"\r\n"];
    NSLog(@"# of items = %d", kwArray.count);
    
    return kwArray;

}

-(void)execute:(NSString *)sql{
    char *cerror;
    if (sqlite3_exec([self.connector database], [sql UTF8String], NULL, NULL, &cerror)!=SQLITE_OK){
        
        NSString *reason = [NSString stringWithFormat:@"Query Error%s",cerror];
        [self.connector closeDB];
        [self throwDBOperationExceptionCausedBy:reason];
    }
}

-(void) bulkTextInsertBySQL:(NSString *)sql andArray:(NSArray *)textArray{
    
    sqlite3_stmt *stmt;
    
    //Prepare the statement
    if (sqlite3_prepare_v2([self.connector database], [sql UTF8String], -1, &stmt, nil) == SQLITE_OK) {
        
        //Bind values
        for(NSString *kw in textArray){
            sqlite3_bind_text(stmt, 1, [kw UTF8String], -1, NULL);
            
            //Step statement
            if (sqlite3_step(stmt) != SQLITE_DONE){
                [self.connector closeDB];
                NSString *reason = [NSString stringWithFormat:@"Error: failed to execute table with message '%s'.", sqlite3_errmsg([self.connector database])];
                [self throwDBOperationExceptionCausedBy:reason];
            }
            sqlite3_reset(stmt);
        }
        
    }
    else{
        [self.connector closeDB];
        NSString *reason = [NSString stringWithFormat:@"!Error: failed to prepare statement with message '%s'.", sqlite3_errmsg([self.connector database])];
        [self throwDBOperationExceptionCausedBy:reason];
    }
    
    //Finalize statement
    sqlite3_finalize(stmt);


}



-(void) throwDBOperationExceptionCausedBy:(NSString *)reason{
    
    NSException* ex = [[NSException alloc]initWithName:@"DBOperationFailures" reason:reason userInfo:nil];
    @throw ex;

}
@end
