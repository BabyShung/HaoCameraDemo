//
//  CameraView.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/4/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//



#define CROPVIEW_HEIGHT 350
#define CROPFRAME_BOARDER_WIDTH 3
#define CROPFRAME_FRAME_WIDTH 220
#define CROPFRAME_FRAME_HEIGHT 80

#define DEFAULT_MASK_ALPHA 0.50

#import "CameraView.h"
#import "CameraManager.h"
#import "ShadeView.h"
#import "ImageCropView.h"
#import "ED_Color.h"
#import "LoadControls.h"

@interface CameraView () <CameraManageCDelegate>
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
}

// Crop View
@property (strong, nonatomic) ImageCropView * CropView;

// Controls
@property (strong, nonatomic) UIButton * backBtn;
@property (strong, nonatomic) UIButton * captureBtn;
@property (strong, nonatomic) UIButton * TorchBtn;
@property (strong, nonatomic) UIButton * saveBtn;
@property (strong, nonatomic) UIButton * nextPageBtn;

@property (strong, nonatomic) UIView * separatorLine;

//previewLayer
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

// View Properties

@property (strong, nonatomic) UIImageView * capturedImageView;//captured image view

@property (strong, nonatomic) CameraManager *camManager;

@property (nonatomic) UIInterfaceOrientation iot;

@end

@implementation CameraView

@synthesize hideAllControls = _hideAllControls, hideBackButton = _hideBackButton, hideCaptureButton = _hideCaptureButton;

- (instancetype)initWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)iot andAppliedVC:(MainViewController *)VC
{
    self = [super initWithFrame:frame];
    if (self) {
        //important
        self.iot = iot;
        self.appliedVC = VC;
        [self setup];
    }
    return self;
}

- (void)resumeCamera{
    [_camManager startRunning];
}

- (void)pauseCamera{
    [_camManager stopRunning];
}

-(BOOL)CameraIsOn{
    return [_camManager isSessionRunning];
}

-(void)checkCameraAndOperate{
    [_camManager isSessionRunning]?[_camManager stopRunning]:[_camManager startRunning];
}


-(void)setup{
    
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor blackColor];
    
    screenWidth = self.bounds.size.width;
    screenHeight = self.bounds.size.height;
    
    //landscape mode
    if  (UIInterfaceOrientationIsLandscape(self.iot))
        self.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    
    //init views
    [self loadViews];
    
    //init camera
    [self loadCamera];
    
    if (self.iot == UIInterfaceOrientationLandscapeLeft) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (self.iot == UIInterfaceOrientationLandscapeRight) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeRight;
    }
    
    //later can change to let user define it
    _isCropMode = YES;
    
    [self checkCropMode];
    
    
    // -- LOAD ROTATION COVERS BEGIN -- //
    /*
     Rotating causes a weird flicker, I'm in the process of looking for a better
     solution, but for now, this works.
     */
    
    // Stream Cover
    _rotationCover = [UIView new];
    _rotationCover.backgroundColor = [UIColor blackColor];
    _rotationCover.bounds = CGRectMake(0, 0, screenHeight * 3, screenHeight * 3); // 1 full screen size either direction
    _rotationCover.center = self.center;
    _rotationCover.autoresizingMask = UIViewAutoresizingNone;
    _rotationCover.alpha = 0;
    [self insertSubview:_rotationCover belowSubview:_StreamView];
    // -- LOAD ROTATION COVERS END -- //
    
    
    // -- PREPARE OUR CONTROLS -- //
    [self loadControls];
}

//delegate method from CameraManager
-(void)imageDidCaptured:(UIImage *)image{
    _capturedImageView.image = image;
    _disablePhotoPreview? [self photoCaptured] : [self drawControls];
}

#pragma mark CAMERA CONTROLS

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
    
    //static CGFloat portraitFontSize = 16.0;
    static CGFloat landscapeFontSize = 12.5;
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        /************************************************************************
         
         Rearranging(not initing) controls based on portrait or landscape
         
         ************************************************************************/
        if (UIInterfaceOrientationIsPortrait(self.iot)) {
            
            CGFloat centerY = screenHeight - 8 - 20; // 8 is offset from bottom (portrait), 20 is half btn height
            
            _backBtn.center = CGPointMake(offsetFromSide + (_backBtn.bounds.size.width / 2), centerY);
            _TorchBtn.center = _backBtn.center;
            
            _captureBtn.bounds = CGRectMake(0, 0, 80, 60);
            _captureBtn.center = CGPointMake(screenWidth/2, centerY - 10);
            
            // offset from backBTN is '20'
            _saveBtn.center = CGPointMake(_TorchBtn.center.x + (_TorchBtn.bounds.size.width / 2) + offsetBetweenButtons + (_saveBtn.bounds.size.width / 2), centerY);
            
            _nextPageBtn.center = CGPointMake(screenWidth - offsetFromSide - (_saveBtn.bounds.size.width / 2), centerY);
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
            _TorchBtn.center = CGPointMake(centerX, _captureBtn.center.y + (_captureBtn.bounds.size.height / 2) + offsetBetweenButtons + (_TorchBtn.bounds.size.height / 2));
            
            // offset from flashBtn is '20'
            _saveBtn.center = CGPointMake(centerX, _TorchBtn.center.y + (_TorchBtn.bounds.size.height / 2) + offsetBetweenButtons + (_saveBtn.bounds.size.height / 2));
            

            // offset from flashBtn is '20'
            _nextPageBtn.center = CGPointMake(centerX, _TorchBtn.center.y + (_TorchBtn.bounds.size.height / 2) + offsetBetweenButtons + (_nextPageBtn.bounds.size.height / 2));
        }
  
        
        // If camera preview -- show preview controls / hide capture controls
        if (_capturedImageView.image) {
            // Hide
            for (UIButton * btn in @[_captureBtn, _TorchBtn]) btn.hidden = YES;
            // Show
            _saveBtn.hidden = NO;
            
            // Force User Preference
            _backBtn.hidden = _hideBackButton;
            
            _backBtn.hidden = NO;
        }
        // ELSE camera stream -- show capture controls / hide preview controls
        else {
            // Show
            for (UIButton * btn in @[_TorchBtn]) btn.hidden = NO;
            // Hide
            _saveBtn.hidden = YES;
            
            // Force User Preference
            _captureBtn.hidden = _hideCaptureButton;
            _backBtn.hidden = _hideBackButton;
            
            _backBtn.hidden = YES;
        }
        
        [self evaluateFlashBtn];
        
    } completion:nil];
}

/******************
 
 Capture a photo
 
 ***************/
- (void) capturePhoto {
    [_camManager capturePhoto:self.iot];
}

- (void) photoCaptured {
    NSLog(@"****************** photoCaptured ********************");
    
    if (isImageResized) {
        NSLog(@"****************** isImageResized ********************");
        
        //[self.camDelegate EdibleCamera:self didFinishWithImage:_capturedImageView.image andImageViewSize:_capturedImageView.image.size];
    }
    else {
        isSaveWaitingForResizedImage = YES;
        [self resizeImage];
    }
    
    //-----For debug
    
    //move tab to 1
    //[self.appliedVC.Maindelegate slideToDebugPage];
    
    //click back btn
    [self backBtnPressed:nil];
    
    //turn torch off if it is on
    [_camManager turnOffTorch:_TorchBtn];
}

#pragma mark BUTTON EVENTS

- (void) captureBtnPressed:(id)sender {
    [self capturePhoto];
}

- (void) saveBtnPressed:(id)sender {
    [self photoCaptured];
}

- (void) torchBtnPressed:(id)sender {
    [_camManager torchBtnPressed:_TorchBtn];
}

- (void) backBtnPressed:(id)sender {
    
    if (_capturedImageView.image) {//already taken
        _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
        _capturedImageView.backgroundColor = [UIColor clearColor];
        _capturedImageView.image = nil;
        
        isRotateWaitingForResizedImage = NO;
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
        
        [self insertSubview:_rotationCover belowSubview:_StreamView];
        
        [self drawControls];
    }
    else {
        //[self.camDelegate EdibleCamera:self didFinishWithImage:_capturedImageView.image andImageViewSize:_capturedImageView.image.size];
    }
}

- (void) nextPagePressed:(id)sender {
    [self.appliedVC.Maindelegate slideToNextPage];
}


- (void) evaluateFlashBtn {
    [_camManager evaluateTorchBtn:_TorchBtn];
}

#pragma mark TAP TO FOCUS

- (void) tapSent:(UITapGestureRecognizer *)sender {
    if (_capturedImageView.image == nil) {
        CGPoint aPoint = [sender locationInView:_StreamView];
        [_camManager focus:aPoint andFocusView:_StreamView];
        
    }
}

#pragma mark RESIZE IMAGE

- (void) resizeImage {
    
    // Set Orientation
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.iot) ? YES : NO;
    
    // Set Size
    CGSize size = (isLandscape) ? CGSizeMake(screenHeight, screenWidth) : CGSizeMake(screenWidth, screenHeight);
    
    if (_isCropMode){//overwrite size since you have a new crop frame
        
        //size = _CropView.bounds.size;
        size = _CropView.cropAreaInView.size;
    }
    
    // Set Draw Rect
    CGRect drawRect = (isLandscape) ? ({
        /**********************
         
         IS CURRENTLY LANDSCAPE
         
         **********************/
        
        CGFloat targetHeight = screenHeight * 0.75; // 3:4 ratio
        
        CGFloat offsetTop = (targetHeight - size.height) / 2;
        CGFloat offsetLeft = (screenHeight - size.width) / 2;
        
        CGRectMake(-offsetLeft, -offsetTop, screenHeight, targetHeight);
    }) : ({
        /**********************
         
         IS CURRENTLY PORTRAIT
         
         **********************/
        
        CGFloat targetWidth = screenHeight * 0.75; // 3:4 ratio
        
        /**********
         Hao fixed
         **********/
        CGFloat offsetTop = _CropView.cropAreaInView.origin.y;
        CGFloat offsetLeft = _CropView.cropAreaInView.origin.x+(targetWidth-screenWidth)/2;
        
        //this rect just fix exactly on iphone5 screen
        CGRectMake(-offsetLeft, -offsetTop, targetWidth, screenHeight);
        
    });
    
    // See if someone's waiting for resized image
    if (isSaveWaitingForResizedImage == YES)
        [self.camDelegate EdibleCamera:self.appliedVC didFinishWithImage:_capturedImageView.image withRect:drawRect andCropSize:size];
    if (isRotateWaitingForResizedImage == YES)
        _capturedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    isImageResized = YES;
}

#pragma mark ROTATION

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration {
    if (_capturedImageView.image) {
        _capturedImageView.backgroundColor = [UIColor blackColor];
        
        // Move for rotation
        [self insertSubview:_rotationCover belowSubview:_capturedImageView];
        
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
        for (UIView * v in @[_capturedImageView, _StreamView, self]) {
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
    
    //first dismiss VC..
    [self.appliedVC dismissViewControllerAnimated:YES completion:^{
        
        completion();
        
        /******************
         
         Clean up
         
         ***************/
        isImageResized = NO;
        isSaveWaitingForResizedImage = NO;
        isRotateWaitingForResizedImage = NO;
        
        [_camManager stopRunning];//key point
        
        
        _capturedImageView.image = nil;
        [_capturedImageView removeFromSuperview];
        _capturedImageView = nil;
        
        [_StreamView removeFromSuperview];
        _StreamView = nil;
        
        [_rotationCover removeFromSuperview];
        _rotationCover = nil;
        
        [_camManager clearResource];
        
        //self.view = nil;
        
        self.camDelegate = nil;
        
        [self.appliedVC removeFromParentViewController];
        
    }];
}


/******************
 
 All the loadings
 
 ***************/
-(void)loadViews{
    /******************
     stream image view
     ***************/
    if (_StreamView == nil)
        _StreamView = [[UIView alloc]init];
    _StreamView.alpha = 0;
    _StreamView.frame = self.bounds;
    
    [self addSubview:_StreamView];
    
    /********************
     captured image view
     ******************/
    if (_capturedImageView == nil)
        _capturedImageView = [[UIImageView alloc]init];
    _capturedImageView.frame = _StreamView.frame; // just to even it out
    _capturedImageView.backgroundColor = [UIColor clearColor];
    _capturedImageView.userInteractionEnabled = YES;
    _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self insertSubview:_capturedImageView aboveSubview:_StreamView];
}

-(void)loadCamera{
    
    _camManager = [[CameraManager alloc]init];
    
    _camManager.imageDelegate = self;
    
    /**************************************************
     Preview layer: has to be added in applying VC
     ***********************************************/
    
    _captureVideoPreviewLayer = [_camManager createPreviewLayer];
	_captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	_captureVideoPreviewLayer.frame = _StreamView.layer.bounds; // parent of layer
    
	[_StreamView.layer addSublayer:_captureVideoPreviewLayer];
    
	[_camManager startRunning];//begin the stream
    
}

-(void)checkCropMode{
    /**********************
     Check crop mode
     *********************/
    if (_isCropMode) {
        NSLog(@"SC: isCropMode");
        _CropView  = [[ImageCropView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, CROPVIEW_HEIGHT)];
        
        [self addSubview:_CropView];
        
        //Hao: since cropview is not whole screen, we need to add a face shade view
        ShadeView *shadeView = [[ShadeView alloc] initWithFrame:CGRectMake(0, CROPVIEW_HEIGHT, screenWidth, screenHeight - CROPVIEW_HEIGHT)];
        
        shadeView.shadeAlpha = DEFAULT_MASK_ALPHA;
        
        [self addSubview:shadeView];
        
        /****************
         Tap for focus
         ***************/
        UITapGestureRecognizer * focusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSent:)];
        focusTap.numberOfTapsRequired = 1;
        [_CropView addGestureRecognizer:focusTap];
        
    }else{
        /****************
         Tap for focus
         ***************/
        UITapGestureRecognizer * focusTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapSent:)];
        focusTap.numberOfTapsRequired = 1;
        [_capturedImageView addGestureRecognizer:focusTap];
    }
}

- (void) loadControls {
    
    // -- LOAD BUTTONS BEGIN -- //
    
    _backBtn = [LoadControls createCameraButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andCenter:CGPointZero];
        [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _TorchBtn = [LoadControls createCameraButton_Image:@"Lightening.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(6, 9, 6, 9) andCenter:CGPointZero];
    [_TorchBtn addTarget:self action:@selector(torchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _saveBtn = [LoadControls createCameraButton_Image:@"Download.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 10.5, 7, 10.5) andCenter:CGPointZero];
    [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _nextPageBtn = [LoadControls createCameraButton_Image:@"CameraNext.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 13, 9, 10) andCenter:CGPointZero];
    [_nextPageBtn addTarget:self action:@selector(nextPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _captureBtn = [LoadControls createCameraButton_Image:@"Camera_01.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsZero andCenter:CGPointZero];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_captureBtn setTitleColor:[ED_Color darkGreyColor] forState:UIControlStateNormal];
    _captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    _captureBtn.titleLabel.numberOfLines = 0;
    _captureBtn.titleLabel.minimumScaleFactor = .5;
    // -- LOAD BUTTONS END -- //
    
    //separator line
    _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(10, 350, 300, 1)];
    _separatorLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:_separatorLine];
    
    for (UIButton * btn in @[_backBtn, _captureBtn, _TorchBtn, _nextPageBtn, _saveBtn])  {
        [self addSubview:btn];
    }

    // Draw camera controls
    [self drawControls];
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
