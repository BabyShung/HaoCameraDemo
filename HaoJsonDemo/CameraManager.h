//
//  CameraManager.h
//  HaoDBCamera
//
//  Created by Hao Zheng on 5/29/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CameraManageCDelegate

@required
//this is because capturing photo is async, when it is done, tell delegate it is done
- (void) imageDidCaptured:(UIImage *) image;
@end


@interface CameraManager : NSObject

@property (retain, nonatomic) id <CameraManageCDelegate> imageDelegate;

//switch camera
-(void)switchCamera;

//session
- (void) startRunning;
- (void) stopRunning;

//torch
-(void)turnOffTorch:(UIButton *)btn;
-(BOOL) torchAvailable;
-(BOOL) torchActive;
-(BOOL)torchToggle;
- (void) evaluateTorchBtn:(UIButton *)btn;
- (void) torchBtnPressed:(UIButton *)btn;

-(AVCaptureVideoPreviewLayer *)createPreviewLayer;

//capture photo
- (void)capturePhoto:(UIInterfaceOrientation)orientation;

//focus a point
-(void)focus:(CGPoint)aPoint andFocusView:(UIView *)view;

//clean up, be careful
-(void)clearResource;

@end
