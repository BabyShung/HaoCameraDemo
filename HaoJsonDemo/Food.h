//
//  Food.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Food : NSObject


@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *foodName;
@property (nonatomic, retain) NSString *tags;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *language;

@property (nonatomic, assign) NSUInteger uid;

@end
