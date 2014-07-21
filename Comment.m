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
        
        self.rate = rate;
        
        self.text = text;
        
    }
    
    return self;
}

-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger)fid andRate:(NSInteger)rate andLike:(NSUInteger)like andDisLike:(NSUInteger)dislike andComment:(NSString *)text andByUser:(OtherUser *)byUser{
    
    if (self = [super init]) {
        
        self.cid = cid;
        
        self.fid = fid;
        
        self.like = like;
        
        self.dislike = dislike;
        
        self.rate = rate;
        
        self.text = text;
        
        self.byUser = byUser;
        
    }
    
    return self;
}

-(instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        self.cid = [[dict objectForKey:@"rid"] intValue];
        self.fid = [[dict objectForKey:@"fid"] intValue];
        self.rate = [[dict objectForKey:@"rate"] intValue];
        self.like = [[dict objectForKey:@"likes"] intValue];
        self.dislike = [[dict objectForKey:@"dislikes"] intValue];
        
        self.text = [dict objectForKey:@"comments"];
        self.createdTime = [[EDTime alloc]initWithTimeIntervalSince1970:[[dict objectForKey:@"last_edit_time"] doubleValue]/1000];
        
        
        NSDictionary *creator = [dict objectForKey:@"review_creater"];
        
        NSString *selfie = [creator objectForKey:@"selfie"];
        NSUInteger uid = [[creator objectForKey:@"uid"] intValue];
        NSUInteger privilege = [[creator objectForKey:@"privilege"] intValue];
        NSString *name = [creator objectForKey:@"name"];
        
        self.byUser = [[OtherUser alloc] initWithUid:uid andUname:name andUtype:privilege andUselfie:selfie];
        
    }
    return self;
}


- (NSString *)description   //toString description
{
    NSString *desc  = [NSString stringWithFormat:@"comment: %@",self.text];
    
    return desc;
    
}

@end
