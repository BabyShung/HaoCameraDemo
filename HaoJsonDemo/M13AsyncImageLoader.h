//
//  M13AsynchronousImageLoader.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M13Async.h"

@interface M13AsyncImageLoader : NSObject

+ (M13AsyncImageLoader *)defaultLoader;

+ (M13AsyncImageLoader *)loaderWithName:(NSString *)name;

+ (void)cleanupLoaderAll;

+ (void)cleanupLoaderWithName:(NSString *)name;

+ (NSCache *)defaultImageCache;

- (void)cancelLoadingImageAtURL:(NSURL *)url;

- (void)cancelLoadingImagesForTarget:(id)target;

- (void)cancelLoadingImageAtURL:(NSURL *)url target:(id)target;

//The cache the image loader will use to cache the images.
@property (nonatomic, strong) NSCache *imageCache;

//The maximum number of images to load concurrently.
@property (nonatomic, assign) NSUInteger maximumNumberOfConcurrentLoads;

//The length of time to try and load an image before stopping.
@property (nonatomic, assign) NSTimeInterval loadingTimeout;

- (void)loadImageAtURLAtAmazon:(NSURL *)url target:(id)target completion:(M13CompletionBlock)completion;

@end
