//
//  SearchDictionary.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/7/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "SearchDictionary.h"
#import "DBOperation.h"

@implementation SearchDictionary


static SearchDictionary *sharedInstance = nil;


+ (SearchDictionary *)sharedInstance{   //directly get the instance
    return sharedInstance;
}

+ (SearchDictionary *)initSharedInstance
{
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[SearchDictionary alloc] init];
        sharedInstance.dict = [[NSMutableDictionary alloc] init];
    });
    return sharedInstance;
}

+ (void)addSearchHistory:(Food*) food{
    if(![sharedInstance.dict objectForKey:food.title]&& food){
        NSLog(@"********** SH: add search histroy ************!! %@",food);
        [sharedInstance.dict setObject:food forKey:food.title];
        NSLog(@"********** SH: add search histroy ************");
    }
}

+(void)removeAllSearchHistory{
    [sharedInstance.dict removeAllObjects];
    NSLog(@"********** SH: remove all search histroy ************");
}

+(void)saveSearchHistoryToLocalDB{
    
    DBOperation *dbo = [[DBOperation alloc] init];
    for(Food * food in [sharedInstance.dict allValues]){
        
        [dbo upsertSearchHistory:food];
        NSLog(@"********** SH: saving search histroy ************");
    }
    //remove all objects for dict
    [self removeAllSearchHistory];
    
}

- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@""];
	return desc;
}
@end
