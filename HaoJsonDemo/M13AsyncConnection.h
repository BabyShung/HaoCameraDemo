//
//  M13AsynchronousImageLoaderConnection.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Edible_S3.h"
#import <AWSRuntime/AWSRuntime.h>
#import "M13Async.h"

/*********************************
 
 Connection class
 
 *********************************/
@interface M13AsyncConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate,AmazonServiceRequestDelegate>

//is loading from Amazon
@property (nonatomic) BOOL fromAmazon;

//The URL of the file to load.
@property (nonatomic, strong) NSURL *fileURL;

//The target of the image loading.
@property (nonatomic, strong) id target;

//The duration of time to wait for a timeout.
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

//The completion block to run once the image is downloaded.
@property (nonatomic, copy) M13CompletionBlock completionBlock;

//The completion block to run once the image has loaded.
- (void)setCompletionBlock:(M13CompletionBlock)completionBlock;

//Begin loading the image.
- (void)startLoading;

//Cancel loading the image.
- (void)cancelLoading;

- (BOOL)isLoading;

- (BOOL)finishedLoading;

@end
