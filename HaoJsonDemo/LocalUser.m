//
//  User.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LocalUser.h"

@implementation LocalUser

static LocalUser *_sharedInstance = nil;

+ (LocalUser *)sharedInstance{   //directly get the instance

    return _sharedInstance;
}

+(LocalUser *)setTONil{
    _sharedInstance = nil;
    return _sharedInstance;
}

+(LocalUser *)cheatingWithUid:(NSString*)uid andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSData*)uselfie{
    _sharedInstance = [[LocalUser alloc] init];
    
    _sharedInstance.Uid = uid;
    _sharedInstance.Uname = uname;
    _sharedInstance.Upwd = upwd;
    _sharedInstance.Utype = utype;
    _sharedInstance.Uselfie = uselfie;
    return _sharedInstance;
}

//static init
+ (LocalUser *)sharedInstanceWithUid:(NSString*)uid andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSData*)uselfie
{
    // 1
    
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LocalUser alloc] init];
        
        _sharedInstance.Uid = uid;
        _sharedInstance.Uname = uname;
        _sharedInstance.Upwd = upwd;
        _sharedInstance.Utype = utype;
        _sharedInstance.Uselfie = uselfie;
    });
    return _sharedInstance;
}


// There’s a lot going on in this short method:
// Declare a static variable to hold the instance of your class, ensuring it’s available globally inside your class.
// Declare the static variable dispatch_once_t which ensures that the initialization code executes only once.
// Use Grand Central Dispatch (GCD) to execute a block which initializes an instance of LibraryAPI.
// This is the essence of the Singleton design pattern: the initializer is never called again once the class has been instantiated.

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@"Uid: %@, Uname: %@, Utype: %lu, Uselfie: %@", self.Uid, self.Uname, (unsigned long)self.Utype, self.Uselfie?@"Yes":@"Nil"];
	
	return desc;
}

@end
