//
//  Comment.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OtherUser.h"

#import "Food.h"


@interface Comment : NSObject

@property (nonatomic, assign) NSUInteger cid;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, assign) NSUInteger rate;

@property (nonatomic, assign) NSUInteger like;

@property (nonatomic, assign) NSUInteger dislike;

@property (nonatomic, assign) NSUInteger fid;

@property (nonatomic, strong) OtherUser *byUser;


//for local user to post or update
-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger )fid andRate:(NSUInteger)rate andComment:(NSString *)comment;

//for initing OtherUser
-(instancetype)initWithCommentID:(NSUInteger)cid andFid:(NSUInteger )fid andRate:(NSUInteger)rate andLike:(NSUInteger)like andDisLike:(NSUInteger)dislike andComment:(NSString *)comment andByUser:(OtherUser *)byUser;


@end