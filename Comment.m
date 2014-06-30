//
//  Comment.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger )fid andRate:(NSUInteger)rate andComment:(NSString *)comment{
  
    if (self = [super init]) {
        
        self.cid = cid;
        
        self.fid = fid;
        
        self.rate = rate;
        
        self.comment = comment;
        
    }
    
    return self;
}

-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger)fid andRate:(NSUInteger)rate andLike:(NSUInteger)like andDisLike:(NSUInteger)dislike andComment:(NSString *)comment andByUser:(OtherUser *)byUser{
    
    if (self = [super init]) {
        
        self.cid = cid;
        
        self.fid = fid;
        
        self.rate = rate;
        
        self.like = like;
        
        self.dislike = dislike;
        
        self.comment = comment;
        
        self.byUser = byUser;
        
    }
    
    return self;
}



- (NSString *)description   //toString description
{
    NSString *desc  = [NSString stringWithFormat:@"comment: %@, rate: %d",self.comment,self.rate];
    
    return desc;
    
}

@end
