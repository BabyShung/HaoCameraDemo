//
//  UIImageView+M13AsynchronousImageView.m
//  M13AsynchronousImageView
//
//  Created by Brandon McQuilkin on 4/24/14.
//  Copyright (c) 2014 Brandon McQuilkin. All rights reserved.
//

#import "UIImageView+M13AsynchronousImageView.h"
#import "M13AsyncImageLoader.h"

/************************************
 
 image load info, starting point
 
 ***********************************/

@implementation UIImageView (M13AsynchronousImageView)

//load image with different loader
- (void)loadImageFromURLAtAmazonAsync:(NSURL *)url withLoaderName:(NSString *)name completion:(M13CompletionBlock)completion
{
    [[M13AsyncImageLoader loaderWithName:name] loadImageAtURLAtAmazon:url target:self completion:^(BOOL success, M13ImageLoadedLocation location, UIImage *image, NSURL *url, id target) {
        //Set the image if loaded
        if (success) {
            
            self.image = image;
            
            if(location == M13ImageLoadedLocationCache){
                NSLog(@"it is cache");
            }else{
                //Hao modified
                [UIView transitionWithView:self
                                  duration:0.6f
                                   options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseInOut
                                animations:^{
                                    self.image = image;
                                } completion:nil];
            }
        }else{
            NSLog(@"network failed");
            //self.image = some network failure image
        }
        //Run the completion
        completion(success, location, image, url, target);
    }];
}


- (void)cancelLoadingAllImages
{
    //need to change
    [[M13AsyncImageLoader defaultLoader] cancelLoadingImagesForTarget:self];
}

- (void)cancelLoadingAllImagesAndLoaderName:(NSString *)loaderName{
    [[M13AsyncImageLoader loaderWithName:loaderName] cancelLoadingImagesForTarget:self];
}


- (void)cancelLoadingImageAtURL:(NSURL *)url
{
    //need to change
    [[M13AsyncImageLoader defaultLoader] cancelLoadingImageAtURL:url target:self];
}

@end
