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
#define BUTTON_Starting_MARGIN_LEFT_RIGHT 30
#define BUTTON_MARGIN_DOWN 12

#import "CameraView.h"
#import "CameraManager.h"
#import "ShadeView.h"
#import "ImageCropView.h"
#import "ED_Color.h"
#import "LoadControls.h"
#import "AppDelegate.h"
#import "LoadingAnimation.h"
#import "Flurry.h"
#import "ASValueTrackingSlider.h"
#import "HaoCaptureButton.h"
#import "LocalizationSystem.h"
#import "DNUtils.h"

@interface CameraView () <CameraManageCDelegate,ASValueTrackingSliderDataSource>
{
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
@property (strong, nonatomic) HaoCaptureButton * captureBtn;
@property (strong, nonatomic) UIButton * TorchBtn;
@property (strong, nonatomic) UIButton * nextPageBtn;
//@property (strong, nonatomic) UIButton * tutorialBtn;
@property (strong, nonatomic) UIButton * rightTopBtn;

//slider
@property (strong, nonatomic) ASValueTrackingSlider *scaleSlider;
//previewLayer
@property (strong, nonatomic) AVCaptureVideoPreviewLayer * captureVideoPreviewLayer;

// View Properties

@property (nonatomic) UIInterfaceOrientation iot;
@property (nonatomic,strong) LoadingAnimation *loadingImage;

@end

@implementation CameraView

@synthesize hideBackButton = _hideBackButton, hideCaptureButton = _hideCaptureButton;

- (instancetype)initWithFrame:(CGRect)frame andOrientation:(UIInterfaceOrientation)iot andAppliedVC:(MainViewController *)VC
{
    self = [super initWithFrame:frame];
    if (self) {
        //important
        self.iot = iot;
        self.appliedVC = VC;
        [self setup];
        //save cameraView reference
        AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDlg.cameraView = self;
        appDlg.nvc = self.appliedVC.navigationController;
        [self registerFocusListener];
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

-(void)resumeCameraWithBlocking{
    [self registerFocusListener];
    //this method is for clicking the back btn in MainVC
    [_camManager startRunningWithBlocking];
}

- (void)resumeCamera{
    [self registerFocusListener];
    [_camManager startRunning];
}

#pragma mark register/unregister: Focus Listener

- (BOOL) isFocusRegistered
{
    return registeredFocusListener;
}

static BOOL registeredFocusListener = NO;
// added by Yang WAN
- (void) registerFocusListener
{
    if (!registeredFocusListener ) {
        // added Yang WAN
        // register observer
        AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        int flags = NSKeyValueObservingOptionNew;
        [camDevice addObserver:self forKeyPath:@"adjustingFocus" options:flags context:nil];
        registeredFocusListener = YES;
        
        // update UI
        UIImage *tickImg = [UIImage imageNamed:@"close-icon.png"];
        [_rightTopBtn setImage:tickImg forState:UIControlStateNormal];
        
        [Flurry logEvent:@"registered focus listener..."];
    }
}

// added by Yang WAN
- (void) unregisterFocusListener
{
    if (registeredFocusListener) {
        // Added by Yang WAN
        // unregister observer
        AVCaptureDevice *camDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        @try{
            [camDevice removeObserver:self forKeyPath:@"adjustingFocus"];
        }@catch(id anException){
            //do nothing, obviously it wasn't attached because an exception was thrown
            // http://stackoverflow.com/questions/1582383/how-can-i-tell-if-an-object-has-a-key-value-observer-attached
            NSLog(@"This is a bad design, but not found better solution yet");
        }
        registeredFocusListener = NO;
        
        // update UI
        UIImage *tickImg = [UIImage imageNamed:@"check_black.png"];
        [_rightTopBtn setImage:tickImg forState:UIControlStateNormal];
        
        [Flurry logEvent:@"unregistered focus listener..."];
    }
}

// callback
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        
        BOOL adjustingFocus = [ [change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1] ];
        NSLog(@"Is adjusting focus? %@", adjustingFocus ? @"YES" : @"NO" );
        NSLog(@"Change dictionary: %@", change);
        
        if (!adjustingFocus) {
            [self captureBtnPressed:nil];
        }
    }
}

- (void) startOrStopFocusListener:(id)sender
{
    if (registeredFocusListener) {
        [self unregisterFocusListener];

    }else{
        [self registerFocusListener];
    }
}

- (void)resumeCameraAndEnterForeground{
    [self registerFocusListener];
    [UIView animateWithDuration:0.3 animations:^{
        self.capturedImageView.backgroundColor = [UIColor clearColor];
    }];
    [_camManager startRunning];
}

- (void)pauseCameraAndEnterBackground{
    [self unregisterFocusListener];
    //setting transition bg
    self.capturedImageView.backgroundColor = [UIColor blackColor];
    [_camManager stopRunning];
}

- (void)pauseCamera{
    [self unregisterFocusListener];
    //setting transition bg
    [_camManager stopRunning];
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
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut  animations:^{
        
        if (UIInterfaceOrientationIsPortrait(self.iot)) {
            
            CGFloat y_bottom_align = screenHeight - _backBtn.bounds.size.height / 2 - BUTTON_MARGIN_DOWN;
            // added by Yang WAN
            // for register/unregister button to the middle at the bottom
            CGFloat x_center = screenWidth / 2;
            
            CGFloat x_left_align = BUTTON_MARGIN_LEFT_RIGHT + (_backBtn.bounds.size.width / 2);
            CGFloat x_right_align = screenWidth - BUTTON_MARGIN_LEFT_RIGHT - (_backBtn.bounds.size.width / 2);
            CGFloat y_middle_align = _backBtn.bounds.size.height/2 + BUTTON_MARGIN_DOWN + screenHeight / 5 * 2;
            
            _backBtn.center = CGPointMake(x_left_align, y_bottom_align);
            
            _captureBtn.center = CGPointMake(screenWidth/2, screenHeight-(iPhone5?100:90));
            
            _nextPageBtn.center = CGPointMake(x_right_align, y_bottom_align);
            
            _rightTopBtn.center = CGPointMake(x_center, y_bottom_align);
            
            _TorchBtn.center = CGPointMake(x_left_align, y_middle_align); // _backBtn.center, changed by Yang WAN
        }
        
        if (_capturedImageView.image) {
            // Hide
            for (UIButton * btn in @[_captureBtn, _TorchBtn, _nextPageBtn, _rightTopBtn]) btn.hidden = YES;
            
        }
        else {  // ELSE camera stream -- show capture controls / hide preview controls
            // Show
            for (UIButton * btn in @[_TorchBtn,_nextPageBtn, _rightTopBtn]) btn.hidden = NO;
            
            
            // Force User Preference
            _captureBtn.hidden = YES; // _hideCaptureButton, changed by Yang WAN
//            _backBtn.hidden = _hideBackButton;
            _backBtn.hidden = YES;
        }
        
        [self evaluateFlashBtn];
        
    } completion:nil];
}

//delegate method from CameraManager
-(void)imageDidCaptured:(UIImage *)image{
    _capturedImageView.image = image;
    
//    [self drawControls];
    
    //start loading animation
    [self startLoadingAnimation];
    
    //don't know why it has to add a little delay, otherwise it will just not show the image first
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    
        [self photoCaptured];
//    });
}

- (void) photoCaptured {
    NSLog(@"****************** photoCaptured ********************");
    isSaveWaitingForResizedImage = YES;
    //turn torch off if it is on
    [_camManager turnOffTorch:_TorchBtn];
    
    //sending back the image back to MVC, the delegate
    [self resizeImage];

}

#pragma mark BUTTON EVENTS


- (void) captureBtnPressed:(id)sender {
    NSLog(@"*********************** pressed *******************************");
    [Flurry logEvent:@"Photo_Taken"];
    
//    self.captureBtn.enabled = NO;
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // this block runs on a background thread
        if (!_camManager.busyNow) {
            _camManager.busyNow = YES;
            [_camManager capturePhoto:self.iot];
        }
        
        // runs on main thread, for UI feedback
        dispatch_async(dispatch_get_main_queue(), ^{
//            busyNow = NO;
        }); // end on main thread block
        
    }); // end of background thread

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
//    self.captureBtn.enabled = YES;
    
    [self drawControls];
    
}

- (void) tutorialPressed:(id)sender {
    NSLog(@"xxxs");
}

- (void) nextPagePressed:(id)sender {
    [Flurry logEvent:@"Next_Page_Pressed"];
    [self unregisterFocusListener];
    [self.appliedVC.Maindelegate slideToNextPage];
}

- (void) evaluateFlashBtn {
    [_camManager evaluateTorchBtn:_TorchBtn];
}

#pragma mark TAP TO FOCUS

- (void) tapSent:(UITapGestureRecognizer *)sender {
    CGPoint aPoint = [sender locationInView:_StreamView];
    [self getCameraFocus:aPoint];
}

-(void)getCameraFocus:(CGPoint)point{
    if (_capturedImageView.image == nil) {
        [_camManager focus:point andFocusView:_StreamView];
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
    if (_capturedImageView == nil){
        _capturedImageView = [[UIImageView alloc]init];
        _capturedImageView.hidden = YES;
    }
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
	[_camManager startRunningWithBlocking];//begin the stream
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
    CGPoint torchStart = CGPointMake(-BUTTON_Starting_MARGIN_LEFT_RIGHT,screenHeight+ halfButtonSize+ BUTTON_MARGIN_DOWN);
    CGPoint nextStart = CGPointMake(screenWidth + BUTTON_Starting_MARGIN_LEFT_RIGHT, screenHeight+ halfButtonSize+ BUTTON_MARGIN_DOWN);
//    CGPoint rightTopBtnPoint = CGPointMake(screenWidth + BUTTON_Starting_MARGIN_LEFT_RIGHT, halfButtonSize + BUTTON_MARGIN_DOWN + screenHeight / 2); // this is useless, added by Yang WAN
    
    // -- LOAD BUTTONS BEGIN -- //
    _backBtn = [LoadControls createRoundedBackButton];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _TorchBtn = [LoadControls createRoundedButton_Image:@"ED_torch.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(0, 0, 0, 0) andLeftBottomElseRightBottom:YES andStartingPosition:torchStart];
    [_TorchBtn addTarget:self action:@selector(torchBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _nextPageBtn = [LoadControls createRoundedButton_Image:@"CameraNext.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(8, 9, 8, 7) andLeftBottomElseRightBottom:NO andStartingPosition:nextStart];
    [_nextPageBtn addTarget:self action:@selector(nextPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //rightTopBtnPoint, not used anymore
    _rightTopBtn = [LoadControls createRoundedButton_Image:@"close-icon.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(8, 9, 8, 7) andLeftBottomElseRightBottom:NO andStartingPosition:CGPointZero];
//    [DNUtils giveMeABorder:_rightTopBtn withColor:[UIColor redColor]];
    
    [_rightTopBtn addTarget:self action:@selector(startOrStopFocusListener:) forControlEvents:UIControlEventTouchUpInside];
    
    _captureBtn = [LoadControls createNiceCameraButton_withCameraView:self];
    [_captureBtn addTarget:self action:@selector(captureBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    // added by Yang WAN
    _captureBtn.hidden = YES;
    _captureBtn.enabled = NO;
    
//    _tutorialBtn = [LoadControls createUIButtonWithRect:CGRectMake(280, 20, 30, 30)];
//    [_tutorialBtn setImage:[UIImage imageNamed:@"ED_about.png"] forState:UIControlStateNormal];
//    [_tutorialBtn setTintColor:[ED_Color edibleBlueColor_Deep]];
//    [_tutorialBtn addTarget:self action:@selector(tutorialPressed:) forControlEvents:UIControlEventTouchUpInside];

    
    // -- LOAD BUTTONS END -- //
    self.scaleSlider = [[ASValueTrackingSlider alloc] initWithFrame:CGRectMake(30, CROPVIEW_HEIGHT, 260, 31)];
    self.scaleSlider.maximumValue = 2.0;
    self.scaleSlider.minimumValue = 1.0;
    NSNumberFormatter *tf = [[NSNumberFormatter alloc] init];
    [tf setPositivePrefix:AMLocalizedString(@"SLIDER_SCALE_TEXT", nil)];
    [self.scaleSlider setNumberFormatter:tf];
    self.scaleSlider.popUpViewCornerRadius = 4.0;
    [self.scaleSlider setMaxFractionDigitsDisplayed:1];
    self.scaleSlider.popUpViewColor = [UIColor colorWithHue:0.55 saturation:0.8 brightness:0.9 alpha:0.7];
    self.scaleSlider.font = [UIFont fontWithName:@"GillSans-Bold" size:22];
    self.scaleSlider.textColor = [UIColor colorWithHue:0.55 saturation:1.0 brightness:0.5 alpha:1];
    self.scaleSlider.dataSource = self;
    self.scaleSlider.value = 1.0f;
    
    // added by Yang WAN, requested by YiZHANG
    self.scaleSlider.hidden = YES;
    self.scaleSlider.enabled = NO;
    
    for (UIButton * btn in @[_captureBtn, _backBtn, _TorchBtn, _nextPageBtn, _scaleSlider, _rightTopBtn])  {
        [self addSubview:btn];
    }
    // Draw camera controls
    [self drawControls];
}

#pragma mark - ASValueTrackingSliderDataSource

- (NSString *)slider:(ASValueTrackingSlider *)slider stringForValue:(float)value;{
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

-(ImageCropView *)getCropView{
    return self.CropView;
}

-(void)updateUILanguage{
    self.captureBtn.detailTextLabel.text = AMLocalizedString(@"CAPTURE_BTN", nil);
    NSNumberFormatter *tf = [[NSNumberFormatter alloc] init];
    [tf setPositivePrefix:AMLocalizedString(@"SLIDER_SCALE_TEXT", nil)];
    [self.scaleSlider setNumberFormatter:tf];
    self.scaleSlider.popUpViewCornerRadius = 4.0;
    [self.scaleSlider setMaxFractionDigitsDisplayed:1];
}

@end