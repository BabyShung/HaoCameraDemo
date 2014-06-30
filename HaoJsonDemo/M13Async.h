//
//  M13Async.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    M13ImageLoadedLocationNone,
    M13ImageLoadedLocationCache,
    M13ImageLoadedLocationLocalFile,
    M13LoadedLocationExternalFile
} M13ImageLoadedLocation;

//completion block
typedef void (^M13CompletionBlock)(BOOL success, M13ImageLoadedLocation location, UIImage *image, NSURL *url, id target);

