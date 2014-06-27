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


-(void)getFoodInfo:(NSString*)foodname andLanguage:(NSString *)language andSELF:(id)selfy;

-(void)getReviews_fid:(NSUInteger)fid andSELF:(id)selfy;

-(void)doComment:(Comment *)comment toFood:(Food *)food withAction:(NSString*)action andSELF:(id)selfy;

-(void)likeOrDislike_rid:(int)rid andLike:(int)like andSELF:(id)selfy;



-(void)performGETAsyncTask:(id)selfy andURLString:(NSString *)urlString;

@end
