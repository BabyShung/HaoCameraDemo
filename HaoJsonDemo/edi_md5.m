//
//  edi_md5.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "edi_md5.h"
#import <CommonCrypto/CommonDigest.h>
@implementation edi_md5


- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

@end
