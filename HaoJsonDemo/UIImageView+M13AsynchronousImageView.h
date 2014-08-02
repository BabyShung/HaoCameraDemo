
#import <UIKit/UIKit.h>

#import "M13Async.h"

@interface UIImageView (M13AsynchronousImageView)

//load image from Amazon
- (void)loadImageFromURLAtAmazonAsync:(NSURL *)url withLoaderName:(NSString *)name completion:(M13CompletionBlock)completion;

//Cancels loading all the images set to load for the image view.
- (void)cancelLoadingAllImages;

- (void)cancelLoadingAllImagesAndLoaderName:(NSString *)loaderName;

//Cancels loading the image at the given URL set to load for the image view.
- (void)cancelLoadingImageAtURL:(NSURL *)url;

@end
