//
//  haoViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "EParentViewController.h"

@class CameraViewController;

/**************
 
 Protocol
 
 ************/

@protocol EdibleCameraDelegate

@required
//Called when the user is done with SimpleCam.  If image is nil, user backed out w/o image.
- (void) EdibleCamera:(CameraViewController *)simpleCam didFinishWithImage:(UIImage *)image;

@optional
//Called when the camera is successfully loaded into the view.
- (void) EdibleCameraDidLoadCameraIntoView:(CameraViewController *)simpleCam;

@end

/****************
 
 View controller
 
 ***************/




@interface CameraViewController : EParentViewController

/******************
 
 Camera properties
 
 ***************/

//Must adhere to SimpleCamDelegate protocol
@property (retain, nonatomic) id <EdibleCameraDelegate> camDelegate;

//Used if you'd like your pictures cropped to squareMode - defaults to NO (beta)
@property BOOL isCropMode;

//Allow to hide all controls (set to YES to show custom controls)
@property (nonatomic) BOOL hideAllControls;

//Allow to hide the capture button. You can take programmaticaly photo using method 'capturePhoto'
@property (nonatomic) BOOL hideCaptureButton;

//Allow to hide the back button. Used if you want to programmatically control the view flow
@property (nonatomic) BOOL hideBackButton;

//Don't show the preview phase of the photo acquisition
@property (nonatomic) BOOL disablePhotoPreview;


/******************
 
 Camera operations
 
 ***************/

// Use this to close SimpleCam - Otherwise, the captureSession may not close properly and may result in memory leaks.
- (void) closeWithCompletion:(void (^)(void))completion;

//Use this method for programmatically acquire a photo
- (void) capturePhoto;


@end
