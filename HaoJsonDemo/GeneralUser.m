//
//  GeneralUser.m
//  HaoTestGetRequest
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "GeneralUser.h"

@implementation GeneralUser

- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@"Uid: %@, Uname: %@", self.Uid, self.Uname];
	return desc;
}


@end
