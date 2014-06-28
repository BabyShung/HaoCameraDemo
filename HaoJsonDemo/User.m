//
//  User.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "User.h"

@implementation User

static User *_sharedInstance = nil;

+ (User *)sharedInstance{   //directly get the instance

    return _sharedInstance;
}

//static init
+ (User *)sharedInstanceWithUid:(NSUInteger)uid andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSData*)uselfie
{
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[User alloc] init];
        
        _sharedInstance.Uid = uid;
        _sharedInstance.Uname = uname;
        _sharedInstance.Upwd = upwd;
        _sharedInstance.Utype = utype;
        _sharedInstance.Uselfie = uselfie;
    });
    return _sharedInstance;
}


- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@"Uid: %d, Uname: %@, Utype: %lu, Uselfie: %@", self.Uid, self.Uname, (unsigned long)self.Utype, self.Uselfie?@"Yes":@"Nil"];
	
	return desc;
}

+(void)ClearUser{
    _sharedInstance = nil;
}

@end
