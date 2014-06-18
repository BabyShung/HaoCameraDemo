//
//  Review.m
//  HaoTestGetRequest
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Review.h"

@implementation Review


- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@"title: %@, comment: %@, rate: %d, user_id: %d, user_name: %@", self.title, self.comment,self.rate,self.byUser.Uid,self.byUser.Uname];
	return desc;
}


@end
