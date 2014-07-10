//
//  User.h
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Comment.h"

@interface User : NSObject  <NSURLConnectionDataDelegate>

@property (nonatomic) NSUInteger Uid;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *pwd;
@property (nonatomic, assign) NSUInteger type;
@property (nonatomic, retain) NSString *selfie;
@property (nonatomic, retain) Comment *latestComment;

typedef void (^edibleBlock)(NSError *err, BOOL success);

typedef NS_ENUM(NSInteger, UserType){
    AnonymousUser = 1
};


+ (User *)sharedInstance;

+ (User *)sharedInstanceWithUid:(NSUInteger)uid andEmail:(NSString*)email andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSString*)uselfie;

+(void)ClearUserInfo;

+(void)logout;

+(void)loginWithCompletion:(void (^)(NSError *err, BOOL success))block;

+(void)loginWithEmail:(NSString *) email andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block;

+(void)registerWithEmail:(NSString *) email andName:(NSString *)name andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block;

+(void)fetchMyCommentOnFood:(NSUInteger)fid andCompletion:(void (^)(NSError *err, BOOL success))block;

+(void)createComment:(Comment *)comment andCompletion:(void (^)(NSError *err, BOOL success))block;

+(NSDictionary*)toDictionary;

+(User *)fromDictionaryToUser:(NSDictionary *)dict;

+(User *)anonymousLogin;

+(void)sendFeedBack:(NSString*)content andCompletion:(void (^)(NSError *err, BOOL success))block;

@end
