//
//  Comment.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Comment.h"

@implementation Comment

-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger )fid andRate:(NSUInteger)rate andComment:(NSString *)text{
  
    if (self = [super init]) {
        
        self.cid = cid;
        
        self.fid = fid;
        
        self.text = text;
        
    }
    
    return self;
}

-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger)fid andRate:(NSUInteger)rate andLike:(NSUInteger)like andDisLike:(NSUInteger)dislike andComment:(NSString *)text andByUser:(OtherUser *)byUser{
    
    if (self = [super init]) {
        
        self.cid = cid;
        
        self.fid = fid;
        
        self.like = like;
        
        self.dislike = dislike;
        
        self.text = text;
        
        self.byUser = byUser;
        
    }
    
    return self;
}



- (NSString *)description   //toString description
{
    NSString *desc  = [NSString stringWithFormat:@"comment: %@",self.text];
    
    return desc;
    
}

@end
