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
- (void) imageDidCaptured:(UIImage *) image;
@end


@interface CameraManager : NSObject

@property (retain, nonatomic) id <CameraManageCDelegate> imageDelegate;


-(void)switchCamera;

- (void) startRunning;
- (void) stopRunning;

-(void)turnOffTorch:(UIButton *)btn;
-(BOOL) torchAvailable;
-(BOOL) torchActive;
-(BOOL)torchToggle;
- (void) evaluateTorchBtn:(UIButton *)btn;
- (void) torchBtnPressed:(UIButton *)btn;

-(AVCaptureVideoPreviewLayer *)createPreviewLayer;
- (void)capturePhoto:(UIInterfaceOrientation)orientation;

-(void)focus:(CGPoint)aPoint andFocusView:(UIView *)view;

-(void)clearResource;

@end
