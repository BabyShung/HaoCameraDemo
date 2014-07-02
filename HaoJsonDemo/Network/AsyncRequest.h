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
@interface AsyncRequest : NSObject 

-(void)getFoodInfo:(NSString*)foodname andLanguage:(NSString *)language ;

-(void)getReviews_fid:(NSUInteger)fid;

-(void)getReviews_fid:(NSUInteger)fid withLoadSize:(NSUInteger)size andSkip:(NSUInteger)skip;

-(void)doComment:(Comment *)comment rating:(NSUInteger)rate withAction:(NSString*)action;

-(void)likeOrDislike_rid:(int)rid andLike:(int)like ;

-(void)signup_withEmail:(NSString*)email andName:(NSString*)name andPwd:(NSString *)pwd ;

-(void)login_withEmail:(NSString*)email andPwd:(NSString *)pwd ;

-(void)checkEmail:(NSString*)email ;

-(void)performGETAsyncTaskwithURLString:(NSString *)urlString;

-(instancetype)initWithDelegate:(id)selfy;

@end
