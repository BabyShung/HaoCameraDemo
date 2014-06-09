//
//  SQLHelper.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface SQLConnector : NSObject
{
    sqlite3 *database;
}
@property (nonatomic) sqlite3 *database;

/***************************************
 
    Use this method, singleton
 
 **************************************/

+ (SQLConnector *)sharedInstance;


/***************************************
 
    methods
 
 **************************************/

- (NSString *) sqliteDBFilePath;// filePath

- (void) openDB;//open a connection

- (void) closeDB;//close a connection

//Create a writable copy of given file from main bundle to Document folder
- (void) createEditableCopyOf:(NSString *) filename;

//- (void) downloadFile:(NSString *)filename;
@end
