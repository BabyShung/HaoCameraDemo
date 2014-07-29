//
//  CameraManager.m
//  HaoDBCamera
//
//  Created by Hao Zheng on 5/29/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//
#define ButtonAvailableAlpha 0.6
#define ButtonUnavailableAlpha 0.2

#import "CameraManager.h"
#import "ED_Color.h"

@interface CameraManager ()

// AVFoundation Properties
@property (strong, nonatomic) AVCaptureSession * mySesh;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;//for still image
@property (strong, nonatomic) AVCaptureDevice * myDevice;
@property (nonatomic) CGFloat scaleFactor;
@property (strong,nonatomic) UIImage *captureImage;

@end

@implementation CameraManager

-(instancetype)init{
    self = [super init];
    if(self){
        [self setup];
        _scaleFactor = 1.0f;
    }
    return self;
}

#pragma mark - Camera action

-(AVCaptureVideoPreviewLayer *)createPreviewLayer{
    return [[AVCaptureVideoPreviewLayer alloc] initWithSession:_mySesh];
}

-(BOOL)isSessionRunning{
    return [_mySesh isRunning];
}

-(void)startRunningWithBlocking{
    [_mySesh startRunning];
}

- (void) startRunning{
    if(![_mySesh isRunning]){
        NSLog(@"************ Camera Manager Start running ************");
        
        dispatch_queue_t layerQ = dispatch_queue_create("layerQ", NULL);
        dispatch_async(layerQ, ^{
            [_mySesh startRunning];
        });
    }
}

- (void) stopRunning{
    if([_mySesh isRunning]){
        NSLog(@"*********** Camera Manager Stop running ***********");
        dispatch_queue_t layerE = dispatch_queue_create("layerE", NULL);
        dispatch_async(layerE, ^{
            [_mySesh stopRunning];
        });
    }
}

-(void)setScaleFactor:(CGFloat)scaleFactor{
    _scaleFactor = scaleFactor;
}

/********************
 Capture
 *******************/
- (void)capturePhoto:(UIInterfaceOrientation)interfaceOrientation{
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in _stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    [videoConnection setVideoScaleAndCropFactor:_scaleFactor];
    
    /********************
     
     Capture processing
     
     *******************/
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         //captured image
         UIImage * capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
         
         if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
             //*** using REAR camera ***
             if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                 CGImageRef cgRef = capturedImage.CGImage;
                 capturedImage = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationUp];
             }
             else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                 CGImageRef cgRef = capturedImage.CGImage;
                 capturedImage = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationDown];
             }
         }
         else if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
             //*** using FRONT camera ***
             
             // flip to look the same as the camera
             if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
             else {
                 if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
                     capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationDownMirrored];
                 else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
                     capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationUpMirrored];
             }
         }
         //call delegate
         [self.imageDelegate imageDidCaptured:capturedImage];
     }];
}

/********************
 switch camera
 *******************/
-(void)switchCamera{
    if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
        // rear active, switch to front
        _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1];
        
        [_mySesh beginConfiguration];
        AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:nil];
        for (AVCaptureInput * oldInput in _mySesh.inputs) {
            [_mySesh removeInput:oldInput];
        }
        [_mySesh addInput:newInput];
        [_mySesh commitConfiguration];
    }
    else if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
        // front active, switch to rear
        _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
        [_mySesh beginConfiguration];
        AVCaptureDeviceInput * newInput = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:nil];
        for (AVCaptureInput * oldInput in _mySesh.inputs) {
            [_mySesh removeInput:oldInput];
        }
        [_mySesh addInput:newInput];
        [_mySesh commitConfiguration];
    }
}

/********************
 Torch
 *******************/
- (void) evaluateTorchBtn:(UIButton *)btn {
    if (_myDevice.isTorchAvailable) {   // Evaluate Flash Available?
        btn.alpha = ButtonAvailableAlpha;
        
        // Evaluate Flash Active?
        if (_myDevice.isTorchActive) {
            [btn setTintColor:[ED_Color greenColor]];
        }
        else {
            [btn setTintColor:[ED_Color redColor]];
        }
    }
    else {
        btn.alpha = ButtonUnavailableAlpha;
        [btn setTintColor:[ED_Color darkGreyColor]];
    }
}

- (void) torchBtnPressed:(UIButton *)btn {
    if ([_myDevice isTorchAvailable]) {
        if (_myDevice.torchActive) {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.torchMode = AVCaptureTorchModeOff;
                [btn setTintColor:[ED_Color redColor]];
            }
        }
        else {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.torchMode = AVCaptureTorchModeOn;
                [btn setTintColor:[ED_Color greenColor]];
            }
        }
        [_myDevice unlockForConfiguration];
    }
}

-(BOOL) torchAvailable{
    return _myDevice.torchAvailable;
}

-(BOOL) torchActive{
    return _myDevice.isTorchActive;
}

-(BOOL)torchToggle{
    if ([_myDevice isTorchAvailable]) {
        if (_myDevice.torchActive) {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.torchMode = AVCaptureTorchModeOff;
                [_myDevice unlockForConfiguration];
                return NO;
            }
        }
        else {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.torchMode = AVCaptureTorchModeOn;
                [_myDevice unlockForConfiguration];
                return YES;
            }
        }
    }
    return NO;
}

-(void)turnOffTorch:(UIButton *)btn{
    //turn torch off if it is on
    if (_myDevice.torchActive) {
        if([_myDevice lockForConfiguration:nil]) {
            _myDevice.torchMode = AVCaptureTorchModeOff;
            [btn setTintColor:[ED_Color redColor]];
            [_myDevice unlockForConfiguration];
        }
    }
}

-(void)focus:(CGPoint)aPoint andFocusView:(UIView *)view{
    if (_myDevice != nil) {
        if([_myDevice isFocusPointOfInterestSupported] &&
           [_myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            
            // we subtract the point from the width to inverse the focal point
            // focus points of interest represents a CGPoint where
            // {0,0} corresponds to the top left of the picture area, and
            // {1,1} corresponds to the bottom right in landscape mode with the home button on the right—
            // THIS APPLIES EVEN IF THE DEVICE IS IN PORTRAIT MODE
            // (from docs)
            // this is all a touch wonky
            double pX = aPoint.x / view.bounds.size.width;
            double pY = aPoint.y / view.bounds.size.height;
            double focusX = pY;
            // x is equal to y but y is equal to inverse x ?
            double focusY = 1 - pX;
            
            //NSLog(@"SC: about to focus at x: %f, y: %f", focusX, focusY);
            if([_myDevice isFocusPointOfInterestSupported] && [_myDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                
                if([_myDevice lockForConfiguration:nil]) {
                    [_myDevice setFocusPointOfInterest:CGPointMake(focusX, focusY)];
                    [_myDevice setFocusMode:AVCaptureFocusModeAutoFocus];
                    [_myDevice setExposurePointOfInterest:CGPointMake(focusX, focusY)];
                    [_myDevice setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
                    NSLog(@"SC: Done Focusing");
                }
                [_myDevice unlockForConfiguration];
            }
        }
    }
}

-(void)clearResource{
    _stillImageOutput = nil;
    _mySesh = nil;
    _myDevice = nil;
}

-(void)setup{
    /******************
     Session: Photo
     ***************/
    if (_mySesh == nil)
        _mySesh = [[AVCaptureSession alloc] init];
	_mySesh.sessionPreset = AVCaptureSessionPresetPhoto;
    
    /***************************************
     Device: rear camera: 0, front camera: 1
     *******************************************/
    
    if([[AVCaptureDevice devices] count] == 0)//if no device, return
        return;
    _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    
    /******************
     Torch light
     ***************/
    if ([_myDevice isTorchActive] && _myDevice.torchActive && [_myDevice lockForConfiguration:nil]) {
        //NSLog(@"SC: Turning Flash Off ...");
        _myDevice.torchMode = AVCaptureTorchModeOff;
        [_myDevice unlockForConfiguration];
    }
    
    /********************
     Define device input
     *******************/
    NSError * error = nil;
	AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:&error];
    
	if (!input) {// Handle the error appropriately.
		NSLog(@"SC: ERROR: trying to open camera: %@", error);
	}
	[_mySesh addInput:input];
    
    /**********************
     Define device output
     *********************/
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_mySesh addOutput:_stillImageOutput];
}

@end