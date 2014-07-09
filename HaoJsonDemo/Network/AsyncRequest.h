//
//  LoginRegister.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"
#import "Food.h"
#import "ShareData.h"

@interface AsyncRequest : NSObject 

//-(void)getFoodInfo:(NSString*)foodname andLanguage:(NSString *)language ;

-(void)getFoodInfo:(NSString*)foodname andLang:(TargetLang)lang;

-(void)getReviews_fid:(NSUInteger)fid;

-(void)getReviews_fid:(NSUInteger)fid withLoadSize:(NSUInteger)size andSkip:(NSUInteger)skip;

-(void)getReviews_fid:(NSUInteger)fid byUid:(NSUInteger)uid;

-(void)doComment:(Comment *)comment;

//-(void)doComment:(Comment *)comment rating:(NSUInteger)rate withAction:(NSString*)action;

-(void)likeOrDislike_rid:(int)rid andLike:(int)like ;

-(void)signup_withEmail:(NSString*)email andName:(NSString*)name andPwd:(NSString *)pwd ;

-(void)login_withEmail:(NSString*)email andPwd:(NSString *)pwd ;

-(void)checkEmail:(NSString*)email ;

-(void)performGETAsyncTaskwithURLString:(NSString *)urlString;

-(void)sendFeedbackWithContent:(NSString *)content;

-(void)getFoodInfo_byPost:(NSString*)foodname andLanguage:(TargetLang)lang;

-(instancetype)initWithDelegate:(id)selfy;

@end
