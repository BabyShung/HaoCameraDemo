//
//  Comment.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)initWithCommentID:(NSUInteger)cid andFood:(Food *)food andRate:(NSUInteger)rate andComment:(NSString *)comment{
  
    if (self = [super init]) {
        
        self.cid = cid;
        
        self.food = food;
        
        self.rate = rate;
        
        self.comment = comment;
        
    }
    
    return self;
}

- (NSString *)description   //toString description
{
    NSString *desc  = [NSString stringWithFormat:@"comment: %@, rate: %d",self.comment,self.rate];
    
    return desc;
    
}

@end
