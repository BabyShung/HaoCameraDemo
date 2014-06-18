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

-(void)getReviews:(NSString*)foodname andUid:(int)uid andStart:(NSUInteger)start andOffset:(NSUInteger)offset andSELF:(id)selfy;

-(void)doReview:(Review *)review andAction:(NSString*)action andSELF:(id)selfy;

-(void)likeOrDislike_rid:(int)rid andLike:(int)like andSELF:(id)selfy;


@end
