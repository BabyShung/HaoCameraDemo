//
//  CameraViewController.h
//  Edible
//
//  Created by Hao Zheng on 4/12/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

static CGFloat optionAvailableAlpha = 0.6;
static CGFloat optionUnavailableAlpha = 0.2;

#define CROPFRAME_BOARDER_WIDTH 3
#define CROPFRAME_FRAME_WIDTH 220
#define CROPFRAME_FRAME_HEIGHT 80
//x and y are centered
#define CROPFRAME_OFFSET 0


#import "CameraViewController.h"
#import "ImageCropView.h"


@interface CameraViewController ()
{
    // Measurements
    CGFloat screenWidth;
    CGFloat screenHeight;
    CGFloat topX;
    CGFloat topY;
    
    // Resize Toggles
    BOOL isImageResized;
    BOOL isSaveWaitingForResizedImage;
    BOOL isRotateWaitingForResizedImage;
    
    // Capture Toggle
    BOOL isCapturingImage;
    
    
    //CMTime defaultVideoMaxFrameDuration;
    
}

// Used to cover animation flicker during rotation
@property (strong, nonatomic) UIView * rotationCover;

// Crop View
@property (strong, nonatomic) ImageCropView * CropView;

// Controls
@property (strong, nonatomic) UIButton * backBtn;
@property (strong, nonatomic) UIButton * captureBtn;
@property (strong, nonatomic) UIButton * flashBtn;
@property (strong, nonatomic) UIButton * switchCameraBtn;
@property (strong, nonatomic) UIButton * saveBtn;

// AVFoundation Properties
@property (strong, nonatomic) AVCaptureSession * mySesh;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;//for still image
@property (strong, nonatomic) AVCaptureDevice * myDevice;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;
//@property (nonatomic, strong) AVCaptureDeviceFormat *defaultFormat;


// View Properties
@property (strong, nonatomic) UIView * StreamView;//STREAM of the realtime photo data
@property (strong, nonatomic) UIImageView * capturedImageView;//captured image view

@end

@implementation CameraViewController;

@synthesize hideAllControls = _hideAllControls, hideBackButton = _hideBackButton, hideCaptureButton = _hideCaptureButton;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    screenWidth = self.view.bounds.size.width;
    screenHeight = self.view.bounds.size.height;
    
    //landscape mode
    if  (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) self.view.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    
    if (_StreamView == nil)
        _StreamView = [[UIView alloc]init];
    _StreamView.alpha = 0;
    _StreamView.frame = self.view.bounds;
    [self.view addSubview:_StreamView];
    
    if (_capturedImageView == nil)
        _capturedImageView = [[UIImageView alloc]init];
    _capturedImageView.frame = _StreamView.frame; // just to even it out
    _capturedImageView.backgroundColor = [UIColor clearColor];
    _capturedImageView.userInteractionEnabled = YES;
    _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view insertSubview:_capturedImageView aboveSubview:_StreamView];
    
    // for focus
    UITapGestureRecognizer * focusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSent:)];
    focusTap.numberOfTapsRequired = 1;
    [_capturedImageView addGestureRecognizer:focusTap];
    
    
    
    /******************
     
     Setup Camera
     
     ***************/
    
    
    /******************
     Session: Photo
     ***************/
    if (_mySesh == nil) _mySesh = [[AVCaptureSession alloc] init];
	_mySesh.sessionPreset = AVCaptureSessionPresetPhoto;
    
    /******************
     Preview layer
     ***************/
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_mySesh];
	_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	_captureVideoPreviewLayer.frame = _StreamView.layer.bounds; // parent of layer
    
	[_StreamView.layer addSublayer:_captureVideoPreviewLayer];
	
    /***************************************
     Device: rear camera: 0, front camera: 1
     *******************************************/
    _myDevice = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0];
    
    /******************
     Flash light
     ***************/
    if ([_myDevice isFlashAvailable] && _myDevice.flashActive && [_myDevice lockForConfiguration:nil]) {
        //NSLog(@"SC: Turning Flash Off ...");
        _myDevice.flashMode = AVCaptureFlashModeOff;
        [_myDevice unlockForConfiguration];
    }
    
    /*************************************
     Format: save the default format
    ************************************/
    //self.defaultFormat = _myDevice.activeFormat;
    //defaultVideoMaxFrameDuration = _myDevice.activeVideoMaxFrameDuration;
//    [_myDevice lockForConfiguration:nil];
//    
//    _myDevice.activeVideoMinFrameDuration = CMTimeMake(1, (int32_t)60.0);
//    _myDevice.activeVideoMaxFrameDuration = CMTimeMake(1, (int32_t)60.0);
//    [_myDevice unlockForConfiguration];

    
    
    
    /********************
     Define device input
     *******************/
    NSError * error = nil;
	AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:_myDevice error:&error];
    
	if (!input) {// Handle the error appropriately.
		NSLog(@"SC: ERROR: trying to open camera: %@", error);
        [_delegate simpleCam:self didFinishWithImage:_capturedImageView.image];
	}
    
	[_mySesh addInput:input];
    
    /**********************
     Define device output
     *********************/
    _stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [_stillImageOutput setOutputSettings:outputSettings];
    [_mySesh addOutput:_stillImageOutput];
    
    
    
    
    
	[_mySesh startRunning];//begin the stream
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    if (_isCropMode) {
        NSLog(@"SC: isCropMode");
        _CropView  = [[ImageCropView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        //_CropView.backgroundColor = [UIColor clearColor];
        
        
        
        [self.view addSubview:_CropView];
  
    }
    
    
    
    // -- LOAD ROTATION COVERS BEGIN -- //
    /*
     Rotating causes a weird flicker, I'm in the process of looking for a better
     solution, but for now, this works.
     */
    
    // Stream Cover
    _rotationCover = [UIView new];
    _rotationCover.backgroundColor = [UIColor blackColor];
    _rotationCover.bounds = CGRectMake(0, 0, screenHeight * 3, screenHeight * 3); // 1 full screen size either direction
    _rotationCover.center = self.view.center;
    _rotationCover.autoresizingMask = UIViewAutoresizingNone;
    _rotationCover.alpha = 0;
    [self.view insertSubview:_rotationCover belowSubview:_StreamView];
    // -- LOAD ROTATION COVERS END -- //
    
    
    
    // -- PREPARE OUR CONTROLS -- //
    [self loadControls];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _StreamView.alpha = 1;
        _rotationCover.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([(NSObject *)_delegate respondsToSelector:@selector(simpleCamDidLoadCameraIntoView:)]) {
                [_delegate simpleCamDidLoadCameraIntoView:self];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"SC: DID RECIEVE MEMORY WARNING");
    // Dispose of any resources that can be recreated.
}

#pragma mark CAMERA CONTROLS

- (void) loadControls {
    
    // -- LOAD BUTTON IMAGES BEGIN -- //
    UIImage * previousImg = [UIImage imageNamed:@"Previous.png"];
    UIImage * downloadImg = [UIImage imageNamed:@"Download.png"];
    UIImage * lighteningImg = [UIImage imageNamed:@"Lightening.png"];
    UIImage * cameraRotateImg = [UIImage imageNamed:@"CameraRotate.png"];
    // -- LOAD BUTTON IMAGES END -- //
    
    // -- LOAD BUTTONS BEGIN -- //
    _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setImage:previousImg forState:UIControlStateNormal];
    [_backBtn setTintColor:[self redColor]];
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(9, 10, 9, 13)];
    
    _flashBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_flashBtn addTarget:self action:@selector(flashBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_flashBtn setImage:lighteningImg forState:UIControlStateNormal];
    [_flashBtn setTintColor:[self redColor]];
    [_flashBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 9, 6, 9)];
    
    _switchCameraBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_switchCameraBtn setImage:cameraRotateImg forState:UIControlStateNormal];
    [_switchCameraBtn setTintColor:[self blueColor]];
    [_switchCameraBtn setImageEdgeInsets:UIEdgeInsetsMake(9.5, 7, 9.5, 7)];
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_saveBtn setImage:downloadImg forState:UIControlStateNormal];
    [_saveBtn setTintColor:[self blueColor]];
    [_saveBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 10.5, 7, 10.5)];
    
    _captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_captureBtn setTitle:@"C\nA\nP\nT\nU\nR\nE" forState:UIControlStateNormal];
    [_captureBtn setTitleColor:[self darkGreyColor] forState:UIControlStateNormal];
    _captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    _captureBtn.titleLabel.numberOfLines = 0;
    _captureBtn.titleLabel.minimumScaleFactor = .5;
    // -- LOAD BUTTONS END -- //
    
    // Stylize buttons
    for (UIButton * btn in @[_backBtn, _captureBtn, _flashBtn, _switchCameraBtn, _saveBtn])  {
        
        btn.bounds = CGRectMake(0, 0, 40, 40);
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:.96];
        btn.alpha = optionAvailableAlpha;
        btn.hidden = YES;
        
        btn.layer.shouldRasterize = YES;
        btn.layer.rasterizationScale = [UIScreen mainScreen].scale;
        btn.layer.cornerRadius = 4;
        
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 0.5;
        
        [self.view addSubview:btn];
    }
    
    // If a device doesn't have multiple cameras, fade out button ...
    if ([AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count == 1) {
        _switchCameraBtn.alpha = optionUnavailableAlpha;
    }
    else {
        [_switchCameraBtn addTarget:self action:@selector(switchCameraBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // Draw camera controls
    [self drawControls];
}

- (void) drawControls {
    
    if (self.hideAllControls) {
        
        // In case they want to hide after they've been displayed
        // for (UIButton * btn in @[_backBtn, _captureBtn, _flashBtn, _switchCameraBtn, _saveBtn]) {
        // btn.hidden = YES;
        // }
        return;
    }
    
    static int offsetFromSide = 10;
    static int offsetBetweenButtons = 20;
    
    static CGFloat portraitFontSize = 16.0;
    static CGFloat landscapeFontSize = 12.5;
    
    [UIView animateWithDuration:.35 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        
        /************************************************************************
         
         Rearranging(not initing) controls based on portrait or landscape
         
         ************************************************************************/
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            
            CGFloat centerY = screenHeight - 8 - 20; // 8 is offset from bottom (portrait), 20 is half btn height
            
            _backBtn.center = CGPointMake(offsetFromSide + (_backBtn.bounds.size.width / 2), centerY);
            
            // offset from backbtn is '20'
            [_captureBtn setTitle:@"CAPTURE" forState:UIControlStateNormal];
            _captureBtn.titleLabel.font = [UIFont systemFontOfSize:portraitFontSize];
            _captureBtn.bounds = CGRectMake(0, 0, 120, 40);
            _captureBtn.center = CGPointMake(_backBtn.center.x + (_backBtn.bounds.size.width / 2) + offsetBetweenButtons + (_captureBtn.bounds.size.width / 2), centerY);
            
            // offset from capturebtn is '20'
            _flashBtn.center = CGPointMake(_captureBtn.center.x + (_captureBtn.bounds.size.width / 2) + offsetBetweenButtons + (_flashBtn.bounds.size.width / 2), centerY);
            
            // offset from flashBtn is '20'
            _switchCameraBtn.center = CGPointMake(_flashBtn.center.x + (_flashBtn.bounds.size.width / 2) + offsetBetweenButtons + (_switchCameraBtn.bounds.size.width / 2), centerY);
            
        }
        else {
            CGFloat centerX = screenHeight - 8 - 20; // 8 is offset from side(landscape), 20 is half btn height
            
            // offset from side is '10'
            _backBtn.center = CGPointMake(centerX, offsetFromSide + (_backBtn.bounds.size.height / 2));
            
            // offset from backbtn is '20'
            [_captureBtn setTitle:@"C\nA\nP\nT\nU\nR\nE" forState:UIControlStateNormal];
            _captureBtn.titleLabel.font = [UIFont systemFontOfSize:landscapeFontSize];
            _captureBtn.bounds = CGRectMake(0, 0, 40, 120);
            _captureBtn.center = CGPointMake(centerX, _backBtn.center.y + (_backBtn.bounds.size.height / 2) + offsetBetweenButtons + (_captureBtn.bounds.size.height / 2));
            
            // offset from capturebtn is '20'
            _flashBtn.center = CGPointMake(centerX, _captureBtn.center.y + (_captureBtn.bounds.size.height / 2) + offsetBetweenButtons + (_flashBtn.bounds.size.height / 2));
            
            // offset from flashBtn is '20'
            _switchCameraBtn.center = CGPointMake(centerX, _flashBtn.center.y + (_flashBtn.bounds.size.height / 2) + offsetBetweenButtons + (_switchCameraBtn.bounds.size.height / 2));
        }
        
        // just so it's ready when we need it to be.
        _saveBtn.frame = _switchCameraBtn.frame;
        
        /*
         Show the proper controls for picture preview and picture stream
         */
        
        // If camera preview -- show preview controls / hide capture controls
        if (_capturedImageView.image) {
            // Hide
            for (UIButton * btn in @[_captureBtn, _flashBtn, _switchCameraBtn]) btn.hidden = YES;
            // Show
            _saveBtn.hidden = NO;
            
            
            // Force User Preference
            _backBtn.hidden = _hideBackButton;
        }
        // ELSE camera stream -- show capture controls / hide preview controls
        else {
            // Show
            for (UIButton * btn in @[_flashBtn, _switchCameraBtn]) btn.hidden = NO;
            // Hide
            _saveBtn.hidden = YES;
            
            // Force User Preference
            _captureBtn.hidden = _hideCaptureButton;
            _backBtn.hidden = _hideBackButton;
        }
        
        [self evaluateFlashBtn];
        
    } completion:nil];
}

/******************
 
 Capture a photo
 
 ***************/
- (void) capturePhoto {
    
    isCapturingImage = YES;
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
         UIImage * capturedImage = [[UIImage alloc]initWithData:imageData scale:1];
         
         if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][0]) {
             //*** using REAR camera ***
             if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
                 CGImageRef cgRef = capturedImage.CGImage;
                 capturedImage = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationUp];
             }
             else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
                 CGImageRef cgRef = capturedImage.CGImage;
                 capturedImage = [[UIImage alloc] initWithCGImage:cgRef scale:1.0 orientation:UIImageOrientationDown];
             }
         }
         else if (_myDevice == [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo][1]) {
             //*** using FRONT camera ***
             
             // flip to look the same as the camera
             if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationLeftMirrored];
             else {
                 if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
                     capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationDownMirrored];
                 else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
                     capturedImage = [UIImage imageWithCGImage:capturedImage.CGImage scale:capturedImage.scale orientation:UIImageOrientationUpMirrored];
             }
             
         }
         
         isCapturingImage = NO;
         _capturedImageView.image = capturedImage;
         imageData = nil;
         
         // If we have disabled the photo preview directly fire the delegate callback, otherwise, show user a preview
         _disablePhotoPreview ? [self photoCaptured] : [self drawControls];
     }];
}

- (void) photoCaptured {
    if (isImageResized) {
        [_delegate simpleCam:self didFinishWithImage:_capturedImageView.image];
    }
    else {
        isSaveWaitingForResizedImage = YES;
        [self resizeImage];
    }
}

#pragma mark BUTTON EVENTS

- (void) captureBtnPressed:(id)sender {
    [self capturePhoto];
}

- (void) saveBtnPressed:(id)sender {
    [self photoCaptured];
}

- (void) flashBtnPressed:(id)sender {
    if ([_myDevice isFlashAvailable]) {
        if (_myDevice.flashActive) {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.flashMode = AVCaptureFlashModeOff;
                [_flashBtn setTintColor:[self redColor]];
            }
        }
        else {
            if([_myDevice lockForConfiguration:nil]) {
                _myDevice.flashMode = AVCaptureFlashModeOn;
                [_flashBtn setTintColor:[self greenColor]];
            }
        }
        [_myDevice unlockForConfiguration];
    }
}

- (void) backBtnPressed:(id)sender {
    if (_capturedImageView.image) {
        _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _capturedImageView.backgroundColor = [UIColor clearColor];
        _capturedImageView.image = nil;
        
        isRotateWaitingForResizedImage = NO;
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
        
        [self.view insertSubview:_rotationCover belowSubview:_StreamView];
        
        [self drawControls];
    }
    else {
        [_delegate simpleCam:self didFinishWithImage:_capturedImageView.image];
    }
}

- (void) switchCameraBtnPressed:(id)sender {
    if (isCapturingImage != YES) {
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
        
        // Need to reset flash btn
        [self evaluateFlashBtn];
    }
}

- (void) evaluateFlashBtn {
    // Evaluate Flash Available?
    if (_myDevice.isFlashAvailable) {
        _flashBtn.alpha = optionAvailableAlpha;
        
        // Evaluate Flash Active?
        if (_myDevice.isFlashActive) {
            [_flashBtn setTintColor:[self greenColor]];
        }
        else {
            [_flashBtn setTintColor:[self redColor]];
        }
    }
    else {
        _flashBtn.alpha = optionUnavailableAlpha;
        [_flashBtn setTintColor:[self darkGreyColor]];
    }
}

#pragma mark TAP TO FOCUS

- (void) tapSent:(UITapGestureRecognizer *)sender {
    
    if (_capturedImageView.image == nil) {
        CGPoint aPoint = [sender locationInView:_StreamView];
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
                double pX = aPoint.x / _StreamView.bounds.size.width;
                double pY = aPoint.y / _StreamView.bounds.size.height;
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
                        //NSLog(@"SC: Done Focusing");
                    }
                    [_myDevice unlockForConfiguration];
                }
            }
        }
    }
}

#pragma mark RESIZE IMAGE

- (void) resizeImage {
    
    // Set Orientation
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? YES : NO;
    
    // Set Size
    CGSize size = (isLandscape) ? CGSizeMake(screenHeight, screenWidth) : CGSizeMake(screenWidth, screenHeight);
    
    if (_isCropMode){//overwrite size since you have a new crop frame
        
        //size = _CropView.bounds.size;
        size = _CropView.cropAreaInView.size;
        
        NSLog(@"X: %f",_CropView.cropAreaInView.origin.x);
        NSLog(@"Y: %f",_CropView.cropAreaInView.origin.y);
        NSLog(@"W: %f",_CropView.cropAreaInView.size.width);
        NSLog(@"H: %f",_CropView.cropAreaInView.size.height);
    }
    
    // Set Draw Rect
    CGRect drawRect = (isLandscape) ? ({
        /**********************
         
         IS CURRENTLY LANDSCAPE
         
         **********************/
        
        // targetHeight is the height our image would need to be at the current screenwidth if we maintained the image ratio.
        CGFloat targetHeight = screenHeight * 0.75; // 3:4 ratio
        
        // we have to draw around the context of the screen
        // our final image will be the image that is left in the frame of the context
        // by drawing outside it, we remove the edges of the picture
        CGFloat offsetTop = (targetHeight - size.height) / 2;
        CGFloat offsetLeft = (screenHeight - size.width) / 2;
        CGRectMake(-offsetLeft, -offsetTop, screenHeight, targetHeight);
    }) : ({
        /**********************
         
         IS CURRENTLY PORTRAIT
         
         **********************/

        // targetWidth is the width our image would need to be at the current screenheight if we maintained the image ratio.
        CGFloat targetWidth = screenHeight * 0.75; // 3:4 ratio
        
        // we have to draw around the context of the screen
        // our final image will be the image that is left in the frame of the context
        // by drawing outside it, we remove the edges of the picture
        CGFloat offsetTop = (screenHeight - size.height) / 2;
        CGFloat offsetLeft = (targetWidth - size.width) / 2;
        CGRectMake(-offsetLeft, -offsetTop, targetWidth, screenHeight);
    });
    
    // START CONTEXT
    UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
    [_capturedImageView.image drawInRect:drawRect];
    _capturedImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // END CONTEXT
    
    
    // See if someone's waiting for resized image
    if (isSaveWaitingForResizedImage == YES) [_delegate simpleCam:self didFinishWithImage:_capturedImageView.image];
    if (isRotateWaitingForResizedImage == YES) _capturedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    isImageResized = YES;
}

#pragma mark ROTATION

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    
    if (_capturedImageView.image) {
        _capturedImageView.backgroundColor = [UIColor blackColor];
        
        // Move for rotation
        [self.view insertSubview:_rotationCover belowSubview:_capturedImageView];
        
        if (!isImageResized) {
            isRotateWaitingForResizedImage = YES;
            [self resizeImage];
        }
    }
    
    CGRect targetRect;
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        targetRect = CGRectMake(0, 0, screenHeight, screenWidth);
        
        if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
        }
        else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
        }
        
    }
    else {
        targetRect = CGRectMake(0, 0, screenWidth, screenHeight);
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    
    
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        for (UIView * v in @[_capturedImageView, _StreamView, self.view]) {
            v.frame = targetRect;
        }
        
        // not in for statement, cuz layer
        _captureVideoPreviewLayer.frame = _StreamView.bounds;
        
    } completion:^(BOOL finished) {
        [self drawControls];
    }];
    
}

#pragma mark CLOSE

- (void) closeWithCompletion:(void (^)(void))completion {
    
    // Need alpha 0.0 before dismissing otherwise sticks out on dismissal
    _rotationCover.alpha = 0.0;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        completion();
        
        /******************
         
         Clean up
         
         ***************/
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
        isRotateWaitingForResizedImage = NO;
        
        [_mySesh stopRunning];
        _mySesh = nil;
        
        _capturedImageView.image = nil;
        [_capturedImageView removeFromSuperview];
        _capturedImageView = nil;
        
        [_StreamView removeFromSuperview];
        _StreamView = nil;
        
        [_rotationCover removeFromSuperview];
        _rotationCover = nil;
        
        _stillImageOutput = nil;
        _myDevice = nil;
        
        self.view = nil;
        _delegate = nil;
        [self removeFromParentViewController];
        
    }];
}

#pragma mark COLORS

- (UIColor *) darkGreyColor {
    return [UIColor colorWithRed:0.226082 green:0.244034 blue:0.297891 alpha:1];
}
- (UIColor *) redColor {
    return [UIColor colorWithRed:1 green:0 blue:0.105670 alpha:.6];
}
- (UIColor *) greenColor {
    return [UIColor colorWithRed:0.128085 green:.749103 blue:0.004684 alpha:0.6];
}
- (UIColor *) blueColor {
    return [UIColor colorWithRed:0 green:.478431 blue:1 alpha:1];
}

#pragma mark STATUS BAR

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark GETTERS | SETTERS

- (void) setHideAllControls:(BOOL)hideAllControls {
    _hideAllControls = hideAllControls;
    
    // This way, hideAllControls can be used as a toggle.
    [self drawControls];
}
- (BOOL) hideAllControls {
    return _hideAllControls;
}
- (void) setHideBackButton:(BOOL)hideBackButton {
    _hideBackButton = hideBackButton;
    _backBtn.hidden = _hideBackButton;
}
- (BOOL) hideBackButton {
    return _hideBackButton;
}
- (void) setHideCaptureButton:(BOOL)hideCaptureButton {
    _hideCaptureButton = hideCaptureButton;
    _captureBtn.hidden = YES;
}
- (BOOL) hideCaptureButton {
    return _hideCaptureButton;
}

@end
