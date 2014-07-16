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

-(UIImage *)getImageFromS3:(NSString *)imageName{
    
    
    @try{
        AmazonS3Client *_s3Client = [[AmazonS3Client alloc]initWithAccessKey:ACCESS_KEY withSecretKey:SECRET_KEY];
        
        S3GetObjectRequest *getObjectRequest = [[S3GetObjectRequest alloc]initWithKey:imageName withBucket:BUCKET_NAME];
        
        
        
        S3GetObjectResponse *response = [_s3Client getObject:getObjectRequest];
        
        if (response.error == nil)
        {
            if (response.body != nil)
            {
                UIImage *someImage = [UIImage imageWithData:response.body];
                NSLog(@"grad image successfully");
                return someImage;
            }
            else{
                NSLog(@"There was no value in the response body");
                return nil;
            }
        }
        else if (response.error != nil)
        {
            NSLog(@"There was an error in the response while getting image: %@",response.error.description);
        }
    }
    
    @catch (NSException *exception) {
        NSLog(@"There was an exception when connecting to s3: %@",exception.description);
    }
    
}

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
