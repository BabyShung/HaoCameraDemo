//
//  haoViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//


#define ButtonAvailableAlpha 0.6
#define ButtonUnavailableAlpha 0.2

#define CROPVIEW_HEIGHT 378
#define CROPFRAME_BOARDER_WIDTH 3
#define CROPFRAME_FRAME_WIDTH 220
#define CROPFRAME_FRAME_HEIGHT 80

#define DEFAULT_MASK_ALPHA 0.50


#import "ShadeView.h"
#import "ImageCropView.h"
#import "CameraViewController.h"
#import "ED_Color.h"

#import "CameraManager.h"

@interface CameraViewController () <CameraManageCDelegate>
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

// Used to cover animation flicker during rotation   ???
@property (strong, nonatomic) UIView * rotationCover;

// Crop View
@property (strong, nonatomic) ImageCropView * CropView;

// Controls
@property (strong, nonatomic) UIButton * backBtn;
@property (strong, nonatomic) UIButton * captureBtn;
@property (strong, nonatomic) UIButton * TorchBtn;
@property (strong, nonatomic) UIButton * saveBtn;

//previewLayer
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

// View Properties
@property (strong, nonatomic) UIView * StreamView;//STREAM of the realtime photo data
@property (strong, nonatomic) UIImageView * capturedImageView;//captured image view

@property (strong, nonatomic) CameraManager *camManager;

@end

@implementation CameraViewController

@synthesize hideAllControls = _hideAllControls, hideBackButton = _hideBackButton, hideCaptureButton = _hideCaptureButton;

//delegate method from CameraManager
-(void)imageDidCaptured:(UIImage *)image{
    _capturedImageView.image = image;
    _disablePhotoPreview? [self photoCaptured] : [self drawControls];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor blackColor];
    
    screenWidth = self.view.bounds.size.width;
    screenHeight = self.view.bounds.size.height;
    
    //landscape mode
    if  (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
        self.view.frame = CGRectMake(0, 0, screenHeight, screenWidth);
    
    //init views
    [self loadViews];
    
    //init camera
    [self loadCamera];
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        _captureVideoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
    }
    else if (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
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
    _rotationCover.center = self.view.center;
    _rotationCover.autoresizingMask = UIViewAutoresizingNone;
    _rotationCover.alpha = 0;
    [self.view insertSubview:_rotationCover belowSubview:_StreamView];
    // -- LOAD ROTATION COVERS END -- //
    
    
    // -- PREPARE OUR CONTROLS -- //
    [self loadControls];
    
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    //Hao: important to change tabbar index
    [self.delegate checkTabbarStatus:self.pageIndex];
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _StreamView.alpha = 1;
        _rotationCover.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([(NSObject *)self.camDelegate respondsToSelector:@selector(EdibleCameraDidLoadCameraIntoView:)]) {
                [self.camDelegate EdibleCameraDidLoadCameraIntoView:self];
            }
        }
    }];
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
            _TorchBtn.center = CGPointMake(_captureBtn.center.x + (_captureBtn.bounds.size.width / 2) + offsetBetweenButtons + (_TorchBtn.bounds.size.width / 2), centerY);
            
            // offset from flashBtn is '20'
            _saveBtn.center = CGPointMake(_TorchBtn.center.x + (_TorchBtn.bounds.size.width / 2) + offsetBetweenButtons + (_saveBtn.bounds.size.width / 2), centerY);
            
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
        }

        /*
         Show the proper controls for picture preview and picture stream
         */
        
        // If camera preview -- show preview controls / hide capture controls
        if (_capturedImageView.image) {
            // Hide
            for (UIButton * btn in @[_captureBtn, _TorchBtn]) btn.hidden = YES;
            // Show
            _saveBtn.hidden = NO;
            
            
            // Force User Preference
            _backBtn.hidden = _hideBackButton;
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
        }
        
        [self evaluateFlashBtn];
        
    } completion:nil];
}

/******************
 
 Capture a photo
 
 ***************/
- (void) capturePhoto {
    [_camManager capturePhoto:self.interfaceOrientation];
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
    [self.delegate moveToTab:1];
    
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
        
        [self.view insertSubview:_rotationCover belowSubview:_StreamView];
        
        [self drawControls];
    }
    else {
        //[self.camDelegate EdibleCamera:self didFinishWithImage:_capturedImageView.image andImageViewSize:_capturedImageView.image.size];
    }
}

- (void) evaluateFlashBtn {
    [_camManager evaluateTorchBtn:_TorchBtn];
}

#pragma mark TAP TO FOCUS

- (void) tapSent:(UITapGestureRecognizer *)sender {
    
    NSLog(@"tapped..");
    
    if (_capturedImageView.image == nil) {
        
        CGPoint aPoint = [sender locationInView:_StreamView];
        [_camManager focus:aPoint andFocusView:_StreamView];
        
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
        
        //CGFloat offsetTop = (screenHeight - size.height) / 2;
        //CGFloat offsetLeft = (targetWidth - size.width) / 2;
        
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
        [self.camDelegate EdibleCamera:self didFinishWithImage:_capturedImageView.image withRect:drawRect andCropSize:size];
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
    
    //first dismiss VC..
    [self dismissViewControllerAnimated:YES completion:^{
        
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
        
        self.view = nil;
        
        self.camDelegate = nil;
        
        [self removeFromParentViewController];
        
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
    _StreamView.frame = self.view.bounds;
    
    [self.view addSubview:_StreamView];
    
    /********************
     captured image view
     ******************/
    if (_capturedImageView == nil)
        _capturedImageView = [[UIImageView alloc]init];
    _capturedImageView.frame = _StreamView.frame; // just to even it out
    _capturedImageView.backgroundColor = [UIColor clearColor];
    _capturedImageView.userInteractionEnabled = YES;
    _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view insertSubview:_capturedImageView aboveSubview:_StreamView];
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
        
        [self.view addSubview:_CropView];
        
        //Hao: since cropview is not whole screen, we need to add a face shade view
        ShadeView *shadeView = [[ShadeView alloc] initWithFrame:CGRectMake(0, CROPVIEW_HEIGHT, screenWidth, screenHeight - CROPVIEW_HEIGHT)];
        
        shadeView.shadeAlpha = DEFAULT_MASK_ALPHA;
        
        [self.view addSubview:shadeView];
        
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
    
    // -- LOAD BUTTON IMAGES BEGIN -- //
    UIImage * previousImg = [UIImage imageNamed:@"Previous.png"];
    UIImage * downloadImg = [UIImage imageNamed:@"Download.png"];
    UIImage * lighteningImg = [UIImage imageNamed:@"Lightening.png"];
    // -- LOAD BUTTON IMAGES END -- //
    
    // -- LOAD BUTTONS BEGIN -- //
    _backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setImage:previousImg forState:UIControlStateNormal];
    [_backBtn setTintColor:[ED_Color redColor]];
    [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(9, 10, 9, 13)];
    
    _TorchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_TorchBtn addTarget:self action:@selector(torchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_TorchBtn setImage:lighteningImg forState:UIControlStateNormal];
    [_TorchBtn setTintColor:[ED_Color redColor]];
    [_TorchBtn setImageEdgeInsets:UIEdgeInsetsMake(6, 9, 6, 9)];
    
    _saveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_saveBtn setImage:downloadImg forState:UIControlStateNormal];
    [_saveBtn setTintColor:[ED_Color blueColor]];
    [_saveBtn setImageEdgeInsets:UIEdgeInsetsMake(7, 10.5, 7, 10.5)];
    
    _captureBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_captureBtn setTitle:@"C\nA\nP\nT\nU\nR\nE" forState:UIControlStateNormal];
    [_captureBtn setTitleColor:[ED_Color darkGreyColor] forState:UIControlStateNormal];
    _captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    _captureBtn.titleLabel.numberOfLines = 0;
    _captureBtn.titleLabel.minimumScaleFactor = .5;
    // -- LOAD BUTTONS END -- //
    
    // Stylize buttons
    for (UIButton * btn in @[_backBtn, _captureBtn, _TorchBtn, _saveBtn])  {
        
        btn.bounds = CGRectMake(0, 0, 40, 40);
        btn.backgroundColor = [UIColor colorWithWhite:1 alpha:.96];
        btn.alpha = ButtonAvailableAlpha;
        btn.hidden = YES;
        
        btn.layer.shouldRasterize = YES;
        btn.layer.rasterizationScale = [UIScreen mainScreen].scale;
        btn.layer.cornerRadius = 4;
        
        btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
        btn.layer.borderWidth = 0.5;
        
        [self.view addSubview:btn];
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
