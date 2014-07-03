//
//  Food.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Food : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic,readonly,getter = isFoodInfoCompleted) BOOL foodInfoComplete;
@property (nonatomic,readonly,getter = isLoadingInfo) BOOL loadingFoodInfo;
@property (nonatomic,readonly,getter = isCommentLoaded) BOOL commentLoaded;
@property (nonatomic,readonly,getter = isLoadingComments) BOOL loadingComments;

@property (nonatomic) NSUInteger fid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *transTitle;
@property (nonatomic, retain) NSString *food_description;
@property (nonatomic, retain) NSArray *tagNames;
@property (nonatomic, strong) NSMutableArray *photoNames;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic) NSUInteger queryTimes;

//For local search results
-(instancetype) initWithTitle:(NSString *)title andTranslations:(NSString *)translate;

-(instancetype) initWithTitle:(NSString *)title andTranslations:(NSString *)translate andQueryTimes:(NSUInteger)queryTimes;

//For Server search results
//-(instancetype) initWithDictionary:(NSDictionary *) dict;


//fetch async food info
-(void) fetchAsyncInfoCompletion:(void (^)(NSError *err, BOOL success))block;

//fetch async comment
-(void) fetchCommentsCompletion:(void (^)(NSError *err, BOOL success))block;
-(void) fetchOldestCommentsSize:(NSUInteger)size andSkip:(NSUInteger)skip completion:(void (^)(NSError *err, BOOL success))block;

@end
