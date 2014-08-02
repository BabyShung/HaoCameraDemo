
#import "UIImageView+M13AsynchronousImageView.h"
#import "M13AsyncImageLoader.h"

/************************************
 
 image load info, starting point
 
 ***********************************/

@implementation UIImageView (M13AsynchronousImageView)

//load image with different loader
- (void)loadImageFromURLAtAmazonAsync:(NSURL *)url withLoaderName:(NSString *)name completion:(M13CompletionBlock)completion{
    
    [[M13AsyncImageLoader loaderWithName:name] loadImageAtURLAtAmazon:url target:self completion:^(BOOL success, M13ImageLoadedLocation location, UIImage *image, NSURL *url, id target) {

        //Run the completion
        completion(success, location, image, url, target);
    }];
}

- (void)cancelLoadingAllImages{
    //need to change
    [[M13AsyncImageLoader defaultLoader] cancelLoadingImagesForTarget:self];
}

- (void)cancelLoadingAllImagesAndLoaderName:(NSString *)loaderName{
    [[M13AsyncImageLoader loaderWithName:loaderName] cancelLoadingImagesForTarget:self];
}

- (void)cancelLoadingImageAtURL:(NSURL *)url{
    //need to change
    [[M13AsyncImageLoader defaultLoader] cancelLoadingImageAtURL:url target:self];
}

@end
