//
//  CameraView.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/4/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#define SCALE_FACTOR 1.0f

#define CROPVIEW_HEIGHT iPhone5?342:282
#define CROPFRAME_BOARDER_WIDTH 3
#define CROPFRAME_FRAME_WIDTH 220
#define CROPFRAME_FRAME_HEIGHT 80

#define CAPTURE_BTN_WIDTH 70
#define CAPTURE_BTN_HEIGHT 70

#define DEFAULT_MASK_ALPHA 0.50

#define BUTTON_MARGIN_LEFT_RIGHT 10

#define BUTTON_MARGIN_DOWN 8


#import "CameraView.h"
#import "CameraManager.h"
#import "ShadeView.h"
#import "ImageCropView.h"
#import "ED_Color.h"
#import "LoadControls.h"
#import "AppDelegate.h"
#import "LoadingAnimation.h"
#import "IPDashedLineView.h"
#import "Flurry.h"
#import "ASValueTrackingSlider.h"

@interface CameraView () <CameraManageCDelegate,ASValueTrackingSliderDataSource>
{
    // Measurements
    CGFloat screenWidth;
    CGFloat screenHeight;
    
    // Resize Toggles
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
@property (strong, nonatomic) UIButton * nextPageBtn;

@property (strong, nonatomic) ASValueTrackingSlider *scaleSlider;

//previewLayer
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

// View Properties

@property (strong, nonatomic) CameraManager *camManager;

@property (nonatomic) UIInterfaceOrientation iot;

@property (nonatomic,strong) LoadingAnimation *loadingImage;

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

-(void)loadLoadingAnimation{
    //start animation
    if(!self.loadingImage){
        self.loadingImage = [[LoadingAnimation alloc] initWithStyle:RTSpinKitViewStyleWave color:[ED_Color edibleBlueColor_Deep]];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.loadingImage.center = CGPointMake(CGRectGetMidX(screenBounds), iPhone5? screenBounds.size.height*0.685:screenBounds.size.height*0.7085);
        [self addSubview:self.loadingImage];
    }
}

-(void)startLoadingAnimation{
    [self.loadingImage startAnimating];
}

-(void)stopLoadingAnimation{
    [self.loadingImage stopAnimating];
}

- (void)resumeCamera{
    [_camManager startRunning];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_camManager startRunning];
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                             (unsigned long)NULL), ^(void) {
//        [_camManager startRunning];
//        self.capturedImageView.backgroundColor = [UIColor clearColor];
//    });
}

- (void)pauseCamera{
    [_camManager stopRunning];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [_camManager stopRunning];
//    });
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                             (unsigned long)NULL), ^(void) {
//        [_camManager stopRunning];
//    });
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
    
    //init loading animation
    [self loadLoadingAnimation];
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
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        if (UIInterfaceOrientationIsPortrait(self.iot)) {
            
            CGFloat centerY = screenHeight - _backBtn.bounds.size.height / 2 - BUTTON_MARGIN_DOWN;
            
            _backBtn.center = CGPointMake(BUTTON_MARGIN_LEFT_RIGHT + (_backBtn.bounds.size.width / 2), centerY);
            _TorchBtn.center = _backBtn.center;
            
            _captureBtn.center = CGPointMake(screenWidth/2, screenHeight-(iPhone5?100:90));
            
            _nextPageBtn.center = CGPointMake(screenWidth - BUTTON_MARGIN_LEFT_RIGHT - (_backBtn.bounds.size.width / 2), centerY);
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


//delegate method from CameraManager
-(void)imageDidCaptured:(UIImage *)image{
    
    _capturedImageView.image = image;
    _disablePhotoPreview? [self photoCaptured] : [self drawControls];
    [self photoCaptured];
}

- (void) photoCaptured {
    NSLog(@"****************** photoCaptured ********************");
  
    isSaveWaitingForResizedImage = YES;
    [self resizeImage];

    
    //turn torch off if it is on
    [_camManager turnOffTorch:_TorchBtn];
}

#pragma mark BUTTON EVENTS

- (void) captureBtnPressed:(id)sender {

    [Flurry logEvent:@"Photo_Taken"];
    
    //start loading animation
    [self startLoadingAnimation];
    
    //self.captureBtn.hidden = YES;
    self.captureBtn.enabled = NO;
    
    [self capturePhoto];
}

- (void) captureBtnPressing:(id)sender {
    
    
    NSLog(@"*********************** is pressing *******************************");
}

- (void) torchBtnPressed:(id)sender {
    
    [Flurry logEvent:@"Torch_On"];

    [_camManager torchBtnPressed:_TorchBtn];
}

- (void) backBtnPressed:(id)sender {
    
    _capturedImageView.contentMode = UIViewContentModeScaleAspectFill;
    _capturedImageView.backgroundColor = [UIColor clearColor];
    _capturedImageView.image = nil;
    
    isRotateWaitingForResizedImage = NO;
    isSaveWaitingForResizedImage = NO;
    
    //relative to capture press
    self.captureBtn.enabled = YES;
    
    [self drawControls];
    
}

- (void) nextPagePressed:(id)sender {
    
    [Flurry logEvent:@"Next_Page_Pressed"];

    
    
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
    
	[_StreamView.layer addSublayer:_captureVideoPreviewLayer];
    
    
    [_camManager setScaleFactor:SCALE_FACTOR];
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

    CGFloat halfButtonSize = _backBtn.bounds.size.width/2;
    
    CGPoint torchStart = CGPointMake(halfButtonSize + BUTTON_MARGIN_LEFT_RIGHT,screenHeight+ halfButtonSize+ BUTTON_MARGIN_DOWN);
    

    CGPoint nextStart = CGPointMake(screenWidth - halfButtonSize - BUTTON_MARGIN_LEFT_RIGHT, screenHeight+ halfButtonSize+ BUTTON_MARGIN_DOWN);
    
    
    // -- LOAD BUTTONS BEGIN -- //
    _backBtn = [LoadControls createRoundedBackButton];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _TorchBtn = [LoadControls createRoundedButton_Image:@"ED_torch.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(0, 0, 0, 0) andLeftBottomElseRightBottom:YES andStartingPosition:torchStart];
    [_TorchBtn addTarget:self action:@selector(torchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    
    _nextPageBtn = [LoadControls createRoundedButton_Image:@"CameraNext.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(8, 9, 8, 7) andLeftBottomElseRightBottom:NO andStartingPosition:nextStart];
    [_nextPageBtn addTarget:self action:@selector(nextPagePressed:) forControlEvents:UIControlEventTouchUpInside];

    
    _captureBtn = [LoadControls createNiceCameraButton];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_captureBtn addTarget:self action:@selector(captureBtnPressing:) forControlEvents:UIControlEventTouchDown];
    
    
    // -- LOAD BUTTONS END -- //
    
    //separator line
//    IPDashedLineView *appearance = [IPDashedLineView appearance];
//    [appearance setLineColor:[UIColor whiteColor]];
//    [appearance setLengthPattern:@[@12, @4]];
//    IPDashedLineView *dash0 = [[IPDashedLineView alloc] initWithFrame:CGRectMake(10, CROPVIEW_HEIGHT, 300, 1)];
    //[self addSubview:dash0];
    
    self.scaleSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(30, CROPVIEW_HEIGHT, 260, 31)];
    self.scaleSlider.maximumValue = 2.0;
    self.scaleSlider.minimumValue = 1.0;
    NSNumberFormatter *tf = [[NSNumberFormatter alloc] init];
    [tf setPositivePrefix:@"Scale: "];
    [self.scaleSlider setNumberFormatter:tf];
    self.scaleSlider.popUpViewCornerRadius = 4.0;
    [self.scaleSlider setMaxFractionDigitsDisplayed:1];
    self.scaleSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    self.scaleSlider.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
    self.scaleSlider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    self.scaleSlider.dataSource = self;
    self.scaleSlider.value = 1.0f;
    
    
    
    for (UIButton * btn in @[_captureBtn, _backBtn, _TorchBtn, _nextPageBtn, _scaleSlider])  {
        [self addSubview:btn];
    }
    
    // Draw camera controls
    [self drawControls];
}

#pragma mark - ASValueTrackingSliderDataSource

- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;
{
    NSLog(@"value: %f",value);
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.025];
    [_captureVideoPreviewLayer setAffineTransform:CGAffineTransformMakeScale(value, value)];
    [CATransaction commit];
    
    [_camManager setScaleFactor:value];
    NSString *s;
    return s;
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