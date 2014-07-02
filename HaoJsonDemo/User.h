//
//  User.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject  <NSURLConnectionDataDelegate>

@property (nonatomic) NSUInteger Uid;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pwd;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, retain) NSString *selfie;

typedef void (^edibleBlock)(NSError *err, BOOL success);

+ (User *)sharedInstance;

+ (User *)sharedInstanceWithUid:(NSUInteger)uid andEmail:(NSString*)email andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSString*)uselfie;

+(void)ClearUser;

+(void)logout;

+(void)loginWithCompletion:(void (^)(NSError *err, BOOL success))block;

+(void)loginWithEmail:(NSString *) email andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block;

+(void)registerWithEmail:(NSString *) email andName:(NSString *)name andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block;

+(NSDictionary*)toDictionary;

@end
