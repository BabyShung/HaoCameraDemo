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

@property (nonatomic,readonly,getter = isCommentsCompleted) BOOL commentsComplete;

@property (nonatomic) NSUInteger fid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *transTitle;
@property (nonatomic, retain) NSString *food_description;
@property (nonatomic, retain) NSMutableArray *tagNames;
@property (nonatomic, strong) NSMutableArray *photoNames;
@property (nonatomic, retain) NSMutableArray *comments;

//For local search results
-(instancetype) initWithTitle:(NSString *)title andTranslations:(NSString *)translate;

//For Server search results
//-(instancetype) initWithDictionary:(NSDictionary *) dict;


//fetch async food info
-(void) fetchAsyncInfoCompletion:(void (^)(NSError *err, BOOL success))block;

//fetch async comment
-(void) fetchCommentsCompletion:(void (^)(NSError *err, BOOL success))block;

@end
