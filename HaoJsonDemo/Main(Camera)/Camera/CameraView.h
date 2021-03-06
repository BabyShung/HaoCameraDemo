//
//  CameraView.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/4/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageCropView;
#import "MainViewController.h"
/**************
 
 Protocol
 
 ************/

@class MainViewController;

@protocol EdibleCameraDelegate

@required
//Called when the user is done with SimpleCam.  If image is nil, user backed out w/o image.
- (void) EdibleCamera:(MainViewController *)simpleCam didFinishWithImage:(UIImage *)image withRect:(CGRect)rect andCropSize:(CGSize)size;

@optional
//Called when the camera is successfully loaded into the view.
- (void) EdibleCameraDidLoadCameraIntoView:(MainViewController *)simpleCam;

@end

@interface CameraView : UIView

/******************
 
 Camera properties
 
 ***************/

//Must adhere to EdibleCameraDelegate protocol
@property (retain, nonatomic) id <EdibleCameraDelegate> camDelegate;

//Used if you'd like your pictures cropped to squareMode - defaults to NO (beta)
@property BOOL isCropMode;

//Allow to hide the capture button. You can take programmaticaly photo using method 'capturePhoto'
@property (nonatomic) BOOL hideCaptureButton;

//Allow to hide the back button. Used if you want to programmatically control the view flow
@property (nonatomic) BOOL hideBackButton;

@property (strong, nonatomic) UIView * StreamView;//bottom view

@property (strong, nonatomic) MainViewController *appliedVC;

@property (strong, nonatomic) UIImageView * capturedImageView;//captured image view

/******************
 
 Camera operations
 
 ***************/

// Use this to close Cam - Otherwise, the captureSession may not close properly and may result in memory leaks.
- (void) closeWithCompletion:(void (^)(void))completion;

- (void) closeWithCompletionWithoutDismissing:(void (^)(void))completion ;

- (instancetype)initWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)iot andAppliedVC:(MainViewController *)VC;

- (void)resumeCamera;
- (void)resumeCameraWithBlocking;
- (void)resumeCameraAndEnterForeground;

- (void)pauseCamera;
- (void)pauseCameraAndEnterBackground;

-(BOOL)CameraIsOn;

-(void)checkCameraAndOperate;

- (void) backBtnPressed:(id)sender;

- (void) nextPagePressed:(id)sender;

- (void) captureBtnPressed:(id)sender;

//loading animation
-(void)startLoadingAnimation;

-(void)stopLoadingAnimation;

-(ImageCropView *)getCropView;

-(void)getCameraFocus:(CGPoint)point;

-(void)updateUILanguage;

@end