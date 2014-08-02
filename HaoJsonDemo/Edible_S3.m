//
//  Edible_S3.m
//  HaoS3Test
//
//  Created by Hao Zheng on 6/16/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Edible_S3.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSS3/AWSS3.h>

#define ACCESS_KEY @"AKIAIUHZFMCZXRKMXF2Q"
#define SECRET_KEY @"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"
#define BUCKET_NAME @"blue-cheese-deployment"

@interface Edible_S3 () <AmazonServiceRequestDelegate>

@end

@implementation Edible_S3

-(void)getImageFromS3Async:(NSString *)imageName andSelfy:(id)selfy{
    AmazonS3Client *_s3Client = [[AmazonS3Client alloc]initWithAccessKey:ACCESS_KEY withSecretKey:SECRET_KEY];
    // create our request
    S3GetObjectRequest *getObjectRequest = [[S3GetObjectRequest alloc] initWithKey:imageName
                                 withBucket:BUCKET_NAME];
    getObjectRequest.delegate = selfy;
    // start asynchronous request
    [_s3Client getObject:getObjectRequest];
}

@end
