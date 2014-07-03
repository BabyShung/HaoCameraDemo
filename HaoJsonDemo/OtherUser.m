//
//  OtherUser.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "OtherUser.h"

@implementation OtherUser

- (instancetype)initWithUid:(NSUInteger)uid andUname:(NSString*)uname andUtype:(NSUInteger)utype andUselfie:(NSString*)uselfie{
    
    if (self = [super init]) {
        
        self.Uid = uid;
        
        self.Uname = uname;
        
        self.Utype = utype;
        
        self.Uselfie = uselfie;
        
    }
    return self;
}

@end
