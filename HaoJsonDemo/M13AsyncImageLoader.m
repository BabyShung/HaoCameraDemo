//
//  M13AsynchronousImageLoader.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "M13AsyncImageLoader.h"
#import "M13AsyncConnection.h"

/*********************************
 
 ImageLoader class
 
 *********************************/

@interface M13AsyncImageLoader ()

//The queue of connections to load image files.
@property (nonatomic, strong) NSMutableArray *connectionQueue;

//The list of active connections.
@property (nonatomic, strong) NSMutableArray *activeConnections;

@end

@implementation M13AsyncImageLoader

+ (M13AsyncImageLoader *)defaultLoader
{
    return [M13AsyncImageLoader loaderWithName:@"Default"];
}

+ (M13AsyncImageLoader *)loaderWithName:(NSString *)name
{
    return [M13AsyncImageLoader loaderWithName:name cleanup:NO];
}

+ (void)cleanupLoaderWithName:(NSString *)name
{
    [M13AsyncImageLoader loaderWithName:name cleanup:YES];
}

+ (M13AsyncImageLoader *)loaderWithName:(NSString *)name cleanup:(BOOL)cleanup
{
    //Create the dictionary to hold the loader if necessary
    static dispatch_once_t onceToken;
    static NSMutableDictionary *loaders;
    dispatch_once(&onceToken, ^{
        loaders = [[NSMutableDictionary alloc] init];
    });
    
    //Create or Cleanup?
    if (!cleanup) {
        //Create / retreive
        if (!loaders[name]) {
            [loaders setObject:[[M13AsyncImageLoader alloc] init] forKey:name];
        }
        
        return loaders[name];
    } else {
        //Remove
        [loaders removeObjectForKey:name];
    }
    
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _imageCache = [M13AsyncImageLoader defaultImageCache];
        _maximumNumberOfConcurrentLoads = 50;
        _loadingTimeout = 30.0;
        _connectionQueue = [NSMutableArray array];
        _activeConnections = [NSMutableArray array];
    }
    return self;
}

+ (NSCache *)defaultImageCache
{
    static dispatch_once_t onceToken;
    static NSCache *defaultCache;
    dispatch_once(&onceToken, ^{
        defaultCache = [[NSCache alloc] init];
    });
    return defaultCache;
}

- (void)loadImageAtURLAtAmazon:(NSURL *)url target:(id)target completion:(M13AsynchronousImageLoaderCompletionBlock)completion
{
    //******** Try loading the image from the cache first.
    
    UIImage *image = [self.imageCache objectForKey:url];
    //If we have the image, return
    if (image) {
        completion(YES, M13AsynchronousImageLoaderImageLoadedLocationCache, image, url, target);
        return;
    }
    
    //******** Not in cache, load the image from Amazon ***************.
    
    
    M13AsyncConnection *connection = [[M13AsyncConnection alloc] init];
    connection.fromAmazon = YES;//Hao added *************
    connection.fileURL = url;
    connection.target = target;
    connection.timeoutInterval = _loadingTimeout;
    [connection setCompletionBlock:^(BOOL success, M13AsynchronousImageLoaderImageLoadedLocation location, UIImage *image, NSURL *url, id target) {
        //Add the image to the cache
        if (success) {
            [self.imageCache setObject:image forKey:url];
        }
        
        //Run the completion block
        completion(success, location, image, url, target);
        
        //Update the connections
        [self updateConnections];
    }];
    
    //Add the connection to the queue
    [_connectionQueue addObject:connection];
    //Update the connections
    [self updateConnections];
}


- (void)updateConnections
{
    //First check if any of the active connections are finished.
    NSMutableArray *completedConnections = [NSMutableArray array];
    for (M13AsyncConnection *connection in _activeConnections) {
        if (connection.finishedLoading) {
            [completedConnections addObject:connection];
        }
    }
    //Remove the completed connections
    [_activeConnections removeObjectsInArray:completedConnections];
    [_connectionQueue removeObjectsInArray:completedConnections];
    
    //Check our queue to see if a completed connection loaded an image a connection in the queue is requesting. If so, mark it as completed, and remove it from the queue
    NSMutableArray *completedByProxyConnections = [NSMutableArray array];
    for (M13AsyncConnection *queuedConnection in _connectionQueue) {
        for (M13AsyncConnection *completedConnection in completedConnections) {
            if ([queuedConnection.fileURL isEqual:completedConnection.fileURL]) {
                //Run the queued connection's completion, and add to the array for removal
                [completedByProxyConnections addObject:queuedConnection];
                //Figure out where the file was loaded from. Don't want to use cache, since this was a loaded image.
                M13AsynchronousImageLoaderImageLoadedLocation location = [queuedConnection.fileURL isFileURL] ? M13AsynchronousImageLoaderImageLoadedLocationLocalFile : M13AsynchronousImageLoaderImageLoadedLocationExternalFile;
                //Run the completion.
                M13AsynchronousImageLoaderCompletionBlock completion = queuedConnection.completionBlock;
                completion(YES, location, [self.imageCache objectForKey:queuedConnection.fileURL], queuedConnection.fileURL, queuedConnection.target);
            }
        }
    }
    
    //Remove the completed connections
    [_connectionQueue removeObject:completedByProxyConnections];
    
    //Now start new connections, until we reach the maximum concurrent connections amount.
    for (int i = 0; i < _maximumNumberOfConcurrentLoads - _activeConnections.count; i++) {
        if (i < _connectionQueue.count) {
            M13AsyncConnection *connection = _connectionQueue[i];
            //Start the connection
            [connection startLoading];
            [_activeConnections addObject:connection];
        }
    }
}

- (void)cancelLoadingImageAtURL:(NSURL *)url
{
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    //Cancel all connections for the given target with the given URL.
    for (M13AsyncConnection *connection in _connectionQueue) {
        if ([connection.fileURL isEqual:url]) {
            [connection cancelLoading];
            [objectsToRemove addObject:connection];
        }
    }
    //Remove those connections from the list.
    [_connectionQueue removeObjectsInArray:objectsToRemove];
    [_activeConnections removeObjectsInArray:objectsToRemove];
    [self updateConnections];
}

- (void)cancelLoadingImagesForTarget:(id)target
{
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    //Cancel all connections for the given target.
    for (M13AsyncConnection *connection in _connectionQueue) {
        if (connection.target == target) {
            [connection cancelLoading];
            [objectsToRemove addObject:connection];
        }
    }
    //Remove those connections from the list.
    [_connectionQueue removeObjectsInArray:objectsToRemove];
    [_activeConnections removeObjectsInArray:objectsToRemove];
    [self updateConnections];
}

- (void)cancelLoadingImageAtURL:(NSURL *)url target:(id)target
{
    NSMutableArray *objectsToRemove = [NSMutableArray array];
    //Cancel all connections for the given target with the given URL.
    for (M13AsyncConnection *connection in _connectionQueue) {
        if (connection.target == target && [connection.fileURL isEqual:url]) {
            [connection cancelLoading];
            [objectsToRemove addObject:connection];
        }
    }
    //Remove those connections from the list.
    [_connectionQueue removeObjectsInArray:objectsToRemove];
    [_activeConnections removeObjectsInArray:objectsToRemove];
    [self updateConnections];
}

@end