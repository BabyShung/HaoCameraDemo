//
//  Review.h
//  HaoTestGetRequest
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeneralUser.h"


@interface Review : NSObject

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *comment;
@property (nonatomic, assign) NSUInteger rate;
@property (nonatomic, retain) GeneralUser *byUser;

@end
