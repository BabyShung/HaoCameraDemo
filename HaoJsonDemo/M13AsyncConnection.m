//
//  M13AsynchronousImageLoaderConnection.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/28/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "M13AsyncConnection.h"

@implementation M13AsyncConnection
{
    BOOL loading;
    BOOL receivedData;
    BOOL finished;
    BOOL canceled;
    NSURLConnection *imageConnection;
    NSMutableData *imageData;
}

- (void)setCompletionBlock:(M13CompletionBlock)completionBlock
{
    _completionBlock = completionBlock;
}

- (void)startLoading
{
    //If we are loading, or have finished, return
    if (loading || finished) {
        return;
    }
    
    //Check to see if our URL is != nil
    if (_fileURL == nil) {
        //Fail
        finished = YES;
        _completionBlock(NO, M13ImageLoadedLocationNone, nil, nil, _target);
        return;
    }
    
    //Begin loading
    loading = YES;
    
    
    if(_fromAmazon){
        //input fileURL to Amazon
        Edible_S3 *s3 = [[Edible_S3 alloc]init];
        [s3 getImageFromS3Async:[_fileURL absoluteString]  andSelfy:self];
        
    }else{
        
        if ([_fileURL isFileURL]) {
            
            //Our URL is to a file on the disk, load it asynchronously
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:_fileURL]];
                
                if (image) {
                    //Force image to decompress. UIImage deffers decompression until the image is displayed on screen.
                    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                    [image drawAtPoint:CGPointZero];
                    image = UIGraphicsGetImageFromCurrentImageContext();
                    UIGraphicsEndImageContext();
                    
                    //Success
                    finished = YES;
                    loading = NO;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _completionBlock(YES, M13LoadedLocationExternalFile, image, _fileURL, _target);
                    });
                    
                } else {
                    //Failure
                    
                    finished = YES;
                    loading = NO;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _completionBlock(NO, M13ImageLoadedLocationLocalFile, nil, _fileURL, _target);
                    });
                }
            });
            
        } else {
            //Our URL is to an external file, No caching, we do that ourselves.
            NSURLRequest *request = [NSURLRequest requestWithURL:_fileURL cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:_timeoutInterval];
            //Create a connection
            imageConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [imageConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
            //Start the connection
            [imageConnection start];
        }
        
    }
}

- (void)cancelLoading
{
    canceled = YES;
    
    //Check to see if we are doing anything.
    if (!loading) {
        //Doing nothing, nothing to clean up.
        finished = YES;
        return;
    }
    
    //Clean up
    loading = NO;
    finished = YES;
    [imageConnection cancel];
    imageConnection = nil;
    imageData = nil;
}

- (BOOL)isLoading
{
    return loading;
}

- (BOOL)finishedLoading
{
    return finished;
}

/************************
 
 Amazon delegate
 
 **********************/
-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response{
    //Setup to collect image data
    imageData = [NSMutableData data];
}

-(void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data{
    //Add the received data to the image data
    receivedData = YES;
    [imageData appendData:data];
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    
    NSLog(@"************** S3 ********************************************** S3 ********");
    //Canceled, no need to process image.
    if (canceled) {
        imageData = nil;
        [imageConnection cancel];
        imageConnection = nil;
        return;
    }
    
    if (receivedData) {
        //Still need to work in the background, not the main thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Create the image from the data
            UIImage *image = [UIImage imageWithData:imageData];
            
            imageData = nil;
            imageConnection = nil;
            
            if (image) {
                
                //Force image to decompress. UIImage deffers decompression until the image is displayed on screen.
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //Success
                finished = YES;
                loading = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _completionBlock(YES, M13LoadedLocationExternalFile, image, _fileURL, _target);
                });
                
            } else {
                //Failure
                
                finished = YES;
                loading = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _completionBlock(NO, M13LoadedLocationExternalFile, nil, _fileURL, _target);
                });
            }
        });
        NSLog(@"************** S3 ********************************************** S3 ********222");
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    //Connection failed, failed to load image.
    imageData = nil;
    imageConnection = nil;
    
    finished = YES;
    loading = NO;
    
    NSLog(@"Amazon failed To Load Image: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _completionBlock(NO, M13LoadedLocationExternalFile, nil, _fileURL, _target);
    });
}

/************************
 
 NSURL delegate
 
 **********************/


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    //Setup to collect image data
    imageData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    //Add the received data to the image data
    receivedData = YES;
    [imageData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    //Connection failed, failed to load image.
    imageData = nil;
    imageConnection = nil;
    
    finished = YES;
    loading = NO;
    
    NSLog(@"Failed To Load Image: %@", error.localizedDescription);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _completionBlock(NO, M13LoadedLocationExternalFile, nil, _fileURL, _target);
    });
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //Canceled, no need to process image.
    if (canceled) {
        imageData = nil;
        [imageConnection cancel];
        imageConnection = nil;
        return;
    }
    
    if (receivedData) {
        //Still need to work in the background, not the main thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //Create the image from the data
            UIImage *image = [UIImage imageWithData:imageData];
            
            imageData = nil;
            imageConnection = nil;
            
            if (image) {
                
                //Force image to decompress. UIImage deffers decompression until the image is displayed on screen.
                UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
                [image drawAtPoint:CGPointZero];
                image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                //Success
                finished = YES;
                loading = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _completionBlock(YES, M13LoadedLocationExternalFile, image, _fileURL, _target);
                });
                
            } else {
                //Failure
                
                finished = YES;
                loading = NO;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _completionBlock(NO, M13LoadedLocationExternalFile, nil, _fileURL, _target);
                });
            }
        });
    }
}

@end

