//
//  CameraView.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/4/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#define SCALE_FACTOR 1.5f

#define CROPVIEW_HEIGHT iPhone5?360:300
#define CROPFRAME_BOARDER_WIDTH 3
#define CROPFRAME_FRAME_WIDTH 220
#define CROPFRAME_FRAME_HEIGHT 80

#define CAPTURE_BTN_WIDTH 70
#define CAPTURE_BTN_HEIGHT 70

#define DEFAULT_MASK_ALPHA 0.50

#import "CameraView.h"
#import "CameraManager.h"
#import "ShadeView.h"
#import "ImageCropView.h"
#import "ED_Color.h"
#import "LoadControls.h"
#import "AppDelegate.h"

@interface CameraView () <CameraManageCDelegate>
{
    // Measurements
    CGFloat screenWidth;
    CGFloat screenHeight;
    
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
        
        //NSLog(@"************ before app delegate **************");
        //save reference of camView so that when enter BG will close, etc
        AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        appDlg.cameraView = self;
        appDlg.nvc = self.appliedVC.navigationController;
        
        
    }
    return self;
}

- (void)resumeCamera{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_camManager startRunning];
        [UIView animateWithDuration:0.3 animations:^{
            self.capturedImageView.backgroundColor = [UIColor clearColor];
        }];
    });
}

- (void)pauseCamera{
    dispatch_async(dispatch_get_main_queue(), ^{
        [_camManager stopRunning];
        [UIView animateWithDuration:0.3 animations:^{
            self.capturedImageView.backgroundColor = [UIColor blackColor];
        }];
    });
}

-(BOOL)CameraIsOn{
    return [_camManager isSessionRunning];
}

-(void)checkCameraAndOperate{
    [_camManager isSessionRunning]?[self pauseCamera]:[self resumeCamera];
}

-(void)setup{
    
    self.clipsToBounds = NO;
    self.backgroundColor = [UIColor blackColor];
    
    screenWidth = self.bounds.size.width;
    screenHeight = self.bounds.size.height;
    
    //init views
    [self loadViews];
    
    //init camera
    [self loadCamera];
    
    //later can change to let user define it
    _isCropMode = YES;
    
    [self checkCropMode];
    
    // -- PREPARE OUR CONTROLS -- //
    [self loadControls];
}

//delegate method from CameraManager
-(void)imageDidCaptured:(UIImage *)image{
    
    _capturedImageView.image = image;
    _disablePhotoPreview? [self photoCaptured] : [self drawControls];
    [self photoCaptured];
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
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        if (UIInterfaceOrientationIsPortrait(self.iot)) {
            
            CGFloat centerY = screenHeight - 8 - 20; // 8 is offset from bottom (portrait), 20 is half btn height
            
            _backBtn.center = CGPointMake(offsetFromSide + (_backBtn.bounds.size.width / 2), centerY);
            _TorchBtn.center = _backBtn.center;
            
            _captureBtn.bounds = CGRectMake(0, 0, CAPTURE_BTN_WIDTH, CAPTURE_BTN_HEIGHT);
            _captureBtn.center = CGPointMake(screenWidth/2, centerY - 10);
            
            // offset from backBTN is '20'
            _saveBtn.center = CGPointMake(_TorchBtn.center.x + (_TorchBtn.bounds.size.width / 2) + offsetBetweenButtons + (_saveBtn.bounds.size.width / 2), centerY);
            
            _nextPageBtn.center = CGPointMake(screenWidth - offsetFromSide - (_saveBtn.bounds.size.width / 2), centerY);
        }
        
        if (_capturedImageView.image) {
            // Hide
            for (UIButton * btn in @[_captureBtn, _TorchBtn]) btn.hidden = YES;
            // Show
            //_saveBtn.hidden = NO;
            
            // Force User Preference
            //_backBtn.hidden = _hideBackButton;
            
            //_backBtn.hidden = NO;
        }
        else {  // ELSE camera stream -- show capture controls / hide preview controls
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
    
    //click back btn
    //[self backBtnPressed:nil];
    
    //turn torch off if it is on
    [_camManager turnOffTorch:_TorchBtn];
}

#pragma mark BUTTON EVENTS

- (void) captureBtnPressed:(id)sender {
    [self capturePhoto];
    //[self photoCaptured];
}

- (void) saveBtnPressed:(id)sender {
    [self photoCaptured];
}

- (void) torchBtnPressed:(id)sender {
    [_camManager torchBtnPressed:_TorchBtn];
}

- (void) backBtnPressed:(id)sender {
    
    _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    _capturedImageView.backgroundColor = [UIColor clearColor];
    _capturedImageView.image = nil;
    
    isRotateWaitingForResizedImage = NO;
    isImageResized = NO;
    isSaveWaitingForResizedImage = NO;
    
    
    [self drawControls];
    
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
    
    // Set Size
    CGSize size = CGSizeMake(screenWidth, screenHeight);
    
    if (_isCropMode){ //overwrite size since you have a new crop frame
        size = _CropView.cropAreaInView.size;
    }
    
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
    // Set Draw Rect
    CGRect drawRect = CGRectMake(-offsetLeft, -offsetTop, targetWidth, screenHeight);
    
    // See if someone's waiting for resized image
    if (isSaveWaitingForResizedImage == YES){
        [self.camDelegate EdibleCamera:self.appliedVC didFinishWithImage:_capturedImageView.image withRect:drawRect andCropSize:size];
    }
    if (isRotateWaitingForResizedImage == YES)
        _capturedImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    isImageResized = YES;
}

#pragma mark CLOSE

//dismissVC
- (void) closeWithCompletion:(void (^)(void))completion {
    
    //first dismiss VC..
    [self.appliedVC dismissViewControllerAnimated:YES completion:^{
        
        [self clearResourse:completion];
        
        [self.appliedVC removeFromParentViewController];
        
    }];
}

- (void) closeWithCompletionWithoutDismissing:(void (^)(void))completion {
    [self clearResourse:completion];
}

-(void)clearResourse:(void (^)(void))completion{
    
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
    
    [_camManager clearResource];
    
    self.camDelegate = nil;
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
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [_captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(SCALE_FACTOR, SCALE_FACTOR)];
    [CATransaction commit];
    
    [_camManager setScaleFactor:SCALE_FACTOR];
    
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
    
    //Hao added
    CGFloat horizontalMargin_HalfBtnSize = 30;
    CGFloat bottomMargin_HalfBtnSize = 28;
    CGPoint torchStart = CGPointMake(-horizontalMargin_HalfBtnSize, screenHeight-bottomMargin_HalfBtnSize);
    CGPoint captureStart = CGPointMake( screenWidth/2, screenHeight + bottomMargin_HalfBtnSize);
    CGPoint nextStart = CGPointMake(screenWidth + horizontalMargin_HalfBtnSize, screenHeight -bottomMargin_HalfBtnSize);
    
    
    // -- LOAD BUTTONS BEGIN -- //
    _backBtn = [LoadControls createCameraButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andCenter:CGPointZero andSmallRadius:YES];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _TorchBtn = [LoadControls createCameraButton_Image:@"ED_torch.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(0, 0, 0, 0) andCenter:torchStart andSmallRadius:YES];
    [_TorchBtn addTarget:self action:@selector(torchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _saveBtn = [LoadControls createCameraButton_Image:@"Download.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 10.5, 7, 10.5) andCenter:CGPointZero andSmallRadius:YES];
    [_saveBtn addTarget:self action:@selector(saveBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _nextPageBtn = [LoadControls createCameraButton_Image:@"CameraNext.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 13, 9, 10) andCenter:nextStart andSmallRadius:YES];
    [_nextPageBtn addTarget:self action:@selector(nextPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _captureBtn = [LoadControls createCameraButton_Image:@"Camera_01.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsZero andCenter:captureStart andSmallRadius:NO];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_captureBtn setTitleColor:[ED_Color darkGreyColor] forState:UIControlStateNormal];
    _captureBtn.titleLabel.font = [UIFont systemFontOfSize:12.5];
    _captureBtn.titleLabel.numberOfLines = 0;
    _captureBtn.titleLabel.minimumScaleFactor = .5;
    // -- LOAD BUTTONS END -- //
    
    //separator line
    _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(10, CROPVIEW_HEIGHT, 300, 1)];
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