//
//  CameraManager.m
//  HaoDBCamera
//
//  Created by Hao Zheng on 5/29/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "CameraManager.h"

@interface CameraManager ()

// AVFoundation Properties
@property (strong, nonatomic) AVCaptureSession * mySesh;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;//for still image
@property (strong, nonatomic) AVCaptureDevice * myDevice;

@property (strong,nonatomic) UIImage *captureImage;

@end

@implementation CameraManager

-(instancetype)init{
    self = [super init];
    if(self){
        [self setup];
    }
    return self;
    
}





#pragma mark - Camera action

-(AVCaptureVideoPreviewLayer *)createPreviewLayer{
    return [[AVCaptureVideoPreviewLayer alloc] initWithSession:_mySesh];
}


- (void) startRunning
{
    [_mySesh startRunning];
}

- (void) stopRunning
{
    [_mySesh stopRunning];
}

- (UIImage *)capturePhoto{
    
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
    
    /********************
     
     Capture processing
     
     *******************/
    [_stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
         
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         
         //captured image
         _captureImage = [[UIImage alloc]initWithData:imageData scale:1];
     }];
    return _captureImage;
    
}

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

-(BOOL)turnOffTorch{
    //turn torch off if it is on
    if (_myDevice.torchActive) {
        if([_myDevice lockForConfiguration:nil]) {
            _myDevice.torchMode = AVCaptureTorchModeOff;
            [_myDevice unlockForConfiguration];
            
            return  YES;
        }
    }
    return false;
}


-(void)setup{
    
    /*^^^^^^^^^^^^^^^^^
     
     Setup Camera
     
     ^^^^^^^^^^^^^^^^^*/
    
    
    /******************
     Session: Photo
     ***************/
    if (_mySesh == nil)
        _mySesh = [[AVCaptureSession alloc] init];
	_mySesh.sessionPreset = AVCaptureSessionPresetPhoto;
 
	
    /***************************************
     Device: rear camera: 0, front camera: 1
     *******************************************/
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
        //[self.camDelegate EdibleCamera:self didFinishWithImage:_capturedImageView.image andImageViewSize:_capturedImageView.image.size];
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
