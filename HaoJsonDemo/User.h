//
//  User.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSUInteger Uid;
@property (nonatomic, retain) NSString *Uname;
@property (nonatomic, retain) NSString *Upwd;
@property (nonatomic, assign) NSUInteger Utype;
@property (nonatomic, retain) NSData *Uselfie;

+ (User *)sharedInstance;

+ (User *)sharedInstanceWithUid:(NSUInteger)uid andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSData*)uselfie;

+(void)ClearUser;


@end
