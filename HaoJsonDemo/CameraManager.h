//
//  CameraManager.h
//  HaoDBCamera
//
//  Created by Hao Zheng on 5/29/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface CameraManager : NSObject




-(void)switchCamera;

- (void) startRunning;
- (void) stopRunning;


-(BOOL)turnOffTorch;
-(BOOL) torchAvailable;
-(BOOL) torchActive;
-(BOOL)torchToggle;


-(AVCaptureVideoPreviewLayer *)createPreviewLayer;

@end
