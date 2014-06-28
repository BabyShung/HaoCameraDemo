//
//  UIImageView+M13AsynchronousImageView.h
//  M13AsynchronousImageView
//
//  Created by Brandon McQuilkin on 4/24/14.
//  Copyright (c) 2014 Brandon McQuilkin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "M13Async.h"


/*************************************
 
 UIImageView in Here
 
 *************************************/

@interface UIImageView (M13AsynchronousImageView)

- (void)loadImageFromURLAtAmazonAsync:(NSURL *)url withLoaderName:(NSString *)name completion:(M13AsynchronousImageLoaderCompletionBlock)completion;

//Cancels loading all the images set to load for the image view.
- (void)cancelLoadingAllImages;

//Cancels loading the image at the given URL set to load for the image view.
- (void)cancelLoadingImageAtURL:(NSURL *)url;

@end
