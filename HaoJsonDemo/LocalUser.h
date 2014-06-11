//
//  User.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocalUser : NSObject

@property (nonatomic, retain) NSString *Uid; //email
@property (nonatomic, retain) NSString *Uname;
@property (nonatomic, retain) NSString *Upwd;
@property (nonatomic, assign) NSUInteger Utype;
@property (nonatomic, retain) NSData *Uselfie;

+ (LocalUser *)sharedInstance;

+ (LocalUser *)sharedInstanceWithUid:(NSString*)uid andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSData*)uselfie;

+ (LocalUser *)setTONil;

+ (LocalUser *)cheatingWithUid:(NSString*)uid andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSData*)uselfie;

@end
