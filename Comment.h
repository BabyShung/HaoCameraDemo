//
//  Comment.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "User.h"

#import "Food.h"


@interface Comment : NSObject

@property (nonatomic, assign) NSUInteger cid;

@property (nonatomic, strong) NSString *comment;

@property (nonatomic, assign) NSUInteger rate;

@property (nonatomic, strong) Food *food;


-(instancetype)initWithCommentID:(NSUInteger)cid andFood:(Food *)food andRate:(NSUInteger)rate andComment:(NSString *)comment;


@end