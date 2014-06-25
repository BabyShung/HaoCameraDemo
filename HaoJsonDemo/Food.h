//
//  Food.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"


@interface Food : NSObject


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *transTitle;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSArray *tagNames;
@property (nonatomic, strong) NSArray *photoNames;
@property (nonatomic, retain) Comment *comments;


@property (nonatomic, assign) NSUInteger uid;

@end
