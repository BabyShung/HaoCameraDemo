//
//  LoginRegister.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Review.h"
@interface AsyncRequest : NSObject 


-(void)getFoodInfo:(NSString*)foodname andLanguage:(NSString *)language andSELF:(id)selfy;

-(void)getReviews:(NSString*)foodname andStart:(NSUInteger)start andOffset:(NSUInteger)offset andSELF:(id)selfy;

-(void)postReview:(Review *)review andSELF:(id)selfy;

-(void)likeOrDislike:(NSString *)post_uid andTitle:(NSString *)post_title andLikeByUid:(NSString*)like_uid andLike:(NSInteger)like andSELF:(id)selfy;


@end
