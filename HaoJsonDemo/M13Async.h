//
//  M13Async.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    M13AsynchronousImageLoaderImageLoadedLocationNone,
    M13AsynchronousImageLoaderImageLoadedLocationCache,
    M13AsynchronousImageLoaderImageLoadedLocationLocalFile,
    M13AsynchronousImageLoaderImageLoadedLocationExternalFile
} M13AsynchronousImageLoaderImageLoadedLocation;

typedef void (^M13AsynchronousImageLoaderCompletionBlock)(BOOL success, M13AsynchronousImageLoaderImageLoadedLocation location, UIImage *image, NSURL *url, id target);


@interface M13Async : NSObject

@end
