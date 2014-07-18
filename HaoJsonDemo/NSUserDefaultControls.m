//
//  NSUserDefaultControls.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "NSUserDefaultControls.h"

@implementation NSUserDefaultControls

+(void)saveUserDictionaryIntoNSUserDefault_dict:(NSDictionary *)dict andKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
