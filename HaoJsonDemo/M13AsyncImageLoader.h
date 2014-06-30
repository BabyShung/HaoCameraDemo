//
//  M13AsynchronousImageLoader.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "M13Async.h"

/*************************************
 
 ImageLoader Class
 
 *************************************/

@interface M13AsyncImageLoader : NSObject

/**@name Control Methods*/
/**
 Returns the default asynchronous image loader. The default loader is named "Default". This is the method most people will use to get the image loader.
 
 @return The default asynchronous image loader.
 */
+ (M13AsyncImageLoader *)defaultLoader;
/**
 Returns an asynchronous image loader with the given name. If no loader exists with that name, one will be created.
 
 @param name The name of the asynchronous image loader to retreive.
 
 @return The asynchronous image loader with the given name.
 */
+ (M13AsyncImageLoader *)loaderWithName:(NSString *)name;
/**
 Clears, and removes from memory the asynchronous image loader with the given name.
 
 @param name The name of the asynchronous image loader to cleanup.
 */


+ (void)cleanupLoaderAll;

+ (void)cleanupLoaderWithName:(NSString *)name;
/**
 The cache all asynchronous image loaders will use, unless set otherwise.
 
 @return The default image Cache.
 */
+ (NSCache *)defaultImageCache;



- (void)cancelLoadingImageAtURL:(NSURL *)url;
/**
 Cancel loading the images set to be loaded for the given target.
 
 @param target The target to cancel loading the images for.
 */
- (void)cancelLoadingImagesForTarget:(id)target;
/**
 Cancels loading the image at the given URL, for the given target.
 
 @param url        The URL of the image to cancel.
 @param target     The target to cancel the loading of the image for.
 */
- (void)cancelLoadingImageAtURL:(NSURL *)url target:(id)target;




//The cache the image loader will use to cache the images.
@property (nonatomic, strong) NSCache *imageCache;

//The maximum number of images to load concurrently.
@property (nonatomic, assign) NSUInteger maximumNumberOfConcurrentLoads;

//The length of time to try and load an image before stopping.
@property (nonatomic, assign) NSTimeInterval loadingTimeout;

- (void)loadImageAtURLAtAmazon:(NSURL *)url target:(id)target completion:(M13CompletionBlock)completion;


@end
