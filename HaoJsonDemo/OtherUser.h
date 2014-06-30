//
//  OtherUser.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OtherUser : NSObject

@property (nonatomic) NSUInteger Uid;
@property (nonatomic, retain) NSString *Uname;
@property (nonatomic, assign) NSUInteger Utype;
@property (nonatomic, retain) NSString *Uselfie;

- (instancetype)initWithUid:(NSUInteger)uid andUname:(NSString*)uname andUtype:(NSUInteger)utype andUselfie:(NSString*)uselfie;


@end
