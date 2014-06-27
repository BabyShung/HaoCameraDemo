//
//  Food.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Food.h"

@implementation Food

-(NSString *)description{
    NSString *desc  = [NSString stringWithFormat:@"Title: %@, transTitle: %@", self.title, self.transTitle];
	return desc;
}


@end
