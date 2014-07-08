//
//  SQLHelper.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "SQLConnector.h"
#import "ShareData.h"

static NSString *kSQLiteFileName = @"localDB.db";

@implementation SQLConnector

@synthesize database;


+ (instancetype)sharedInstance
{
    // 1
    static SQLConnector *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
        NSLog(@"DB connector sharedInstance get called only once");
    });
    return _sharedInstance;
}

/*******************************
 
    Basic functions
 
 ******************************/

- (NSString *) sqliteDBFilePath  //get the file path of DB
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kSQLiteFileName];
    [self createEditableCopyOf:kSQLiteFileName];
	NSLog(@"Database path = %@", path);
	
	return path;
}

// open a db connection
- (void) openDB
{
    if (sqlite3_open([[self sqliteDBFilePath] UTF8String], &database) != SQLITE_OK)
	{
        sqlite3_close(database);
        
        NSString *reason = [NSString stringWithFormat:@"Failed to open database with message '%s'.", sqlite3_errmsg(database)];
        [self throwConnectorExceptionCausedBy:reason];
        
    }else{
        NSLog(@"Database opened");
    }
}

// close a db connection
- (void) closeDB
{
    if (sqlite3_close(database) != SQLITE_OK)
	{
        NSString *reason = [NSString stringWithFormat:@"Error: failed to close database with message '%s'.", sqlite3_errmsg(database)];
        [self throwConnectorExceptionCausedBy:reason];
    
    }
    else{
        NSLog(@"Database closed");
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void) createEditableCopyOf:(NSString *)filename
{
    ShareData *sharedata = [ShareData shareData];
    
    // First, test for existence.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:[sharedata writablePathByFileName:filename]];
    
    if (success)
	{
		return;
	}
    
    // The writable file does not exist, so copy the read-only one from main bundle to the writable
    NSError *error;
    NSLog(@"COPY %@",[sharedata readonlyPathByFileName:filename]);
    success = [fileManager copyItemAtPath:[sharedata readonlyPathByFileName:filename] toPath:[sharedata writablePathByFileName:filename] error:&error];
	if (!success)
	{
        NSString *reason = [NSString stringWithFormat:@"Failed to create writable database file with message '%@'.", [error localizedDescription]];
        [self throwConnectorExceptionCausedBy:reason];
        
    }
    else{
        NSLog(@"+++ connector +++ : copy %@ successfully",filename);
    }
}


-(void) throwConnectorExceptionCausedBy:(NSString *)reason{

    NSException* ex = [[NSException alloc]initWithName:@"DBConnectionFailures" reason:reason userInfo:nil];
    @throw ex;

}


@end
