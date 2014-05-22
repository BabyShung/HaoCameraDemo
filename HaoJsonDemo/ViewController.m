//
//  ViewController.m
//  Edible
//
//  Created by Hao Zheng on 4/12/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (strong, nonatomic) UIImageView * imgView;

@property (strong, nonatomic) UILabel * tapLabel;

@property (nonatomic,strong) CameraViewController *CameraVC;

@property (nonatomic) BOOL takePhotoImmediately;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imgView = [UIImageView new];
    _imgView.bounds = CGRectMake(0, 0, 320, 568);
    _imgView.center = self.view.center;
    _imgView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:_imgView];
    
    _tapLabel = [UILabel new];
    _tapLabel.bounds = CGRectMake(0, 0, 200, 100);
    _tapLabel.text = @"TAP TO TAKE PHOTO";
    _tapLabel.textAlignment = NSTextAlignmentCenter;
    _tapLabel.center = self.view.center;
    _tapLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:_tapLabel];
    
    UITapGestureRecognizer * tap = [UITapGestureRecognizer new];
    [tap addTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tap];
}

#pragma mark Tesseract

//tesseract processing
-(void)recognizeImageWithTesseract:(UIImage *)img
{
    Tesseract* tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];//langague package
    tesseract.delegate = self;
    [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" forKey:@"tessedit_char_whitelist"]; //limit search
    [tesseract setImage:img]; //image to check
    [tesseract recognize];//processing
    
    NSString *recognizedText = [tesseract recognizedText];
    NSLog(@"Recognized: %@", recognizedText);
    
    //Threading
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Text detection" message:recognizedText delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
        
    });
    
    tesseract = nil; //deallocate and free all memory *****
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark ACTIONSHEET

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    self.takePhotoImmediately = NO;
    
    switch (buttonIndex) {
        case 0: // default
        {
            CameraViewController * simpleCam = [CameraViewController new];
            simpleCam.delegate= self;
            
            simpleCam.isCropMode = YES;
            
            [self presentViewController:simpleCam animated:YES completion:nil];
        }
            break;
            
        case 1: // take photo immediately
        {
            self.takePhotoImmediately = YES;
            
            CameraViewController * simpleCam = [CameraViewController new];
            simpleCam.delegate= self;
            // [simpleCam setHideCaptureButton:YES];
            // [simpleCam setHideBackButton:YES];
            
            simpleCam.hideAllControls = YES;
            [simpleCam setDisablePhotoPreview:YES];
            
            [self presentViewController:simpleCam animated:YES completion:nil];
        }
            break;
            
        case 2: // overlay
        {
            self.CameraVC = [CameraViewController new];
            self.CameraVC.delegate= self;
            
            //hide all components
            [self.CameraVC setHideAllControls:YES];
            
            [self.CameraVC setDisablePhotoPreview:NO];
            
            CGRect frame;
            frame.size = CGSizeMake(self.view.frame.size.width, 120);
            frame.origin.x = 0;
            frame.origin.y = self.view.frame.size.height -frame.size.height;
            UIView *overlayView = [[UIView alloc] initWithFrame:frame];
            overlayView.backgroundColor = [UIColor blackColor];
            overlayView.alpha = 0.3;
            overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
            
            UIImage *image = [UIImage imageNamed:@"shutter"];
            frame.size = image.size;
            frame.origin.x = (overlayView.frame.size.width -frame.size.width)/2;
            frame.origin.y = (overlayView.frame.size.height -frame.size.height)/2;
            
            UIButton *button = [[UIButton alloc] initWithFrame:frame];
            [button setImage:image forState:UIControlStateNormal];
            [button addTarget:self action:@selector(actionPhoto) forControlEvents:UIControlEventTouchUpInside];
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
            [overlayView addSubview:button];
            
            
            [self.CameraVC.view addSubview:overlayView];
            
            [self presentViewController:self.CameraVC animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark PRIVATE

- (void)actionPhoto     //take photo
{
    [self.CameraVC capturePhoto];
}

#pragma mark TAP RECOGNIZER

- (void) handleTap:(UITapGestureRecognizer *)tap {
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Camera" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Default", @"Take Photo Immediately", @"Custom", nil];
    [sheet showInView:self.view];
}

#pragma mark SIMPLE CAM DELEGATE

- (void) simpleCam:(CameraViewController *)simpleCam didFinishWithImage:(UIImage *)image {
    
    if (image) {
        /*****************************
         
         simple cam finished with image
         
        ****************************/
        _imgView.image = image;
        //_tapLabel.hidden = NO;
        
        _imgView.frame = CGRectMake(_imgView.frame.origin.x, _imgView.frame.origin.y,
                                     image.size.width, image.size.height);
        

        dispatch_async(dispatch_get_main_queue(), ^{
            //1.Use tesseract to recognize image
            [self recognizeImageWithTesseract:image];
            
        });
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //2.save image to album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
        });
        
    }else {// simple cam finished w/o image
        _imgView.image = nil;
        //_tapLabel.hidden = NO;
    }
    
    /*****************************
     
     Close Camera -
     use this as opposed to 'dismissViewController' otherwise,
     the captureSession may not close properly and may result in memory leaks.
    
    *********************************/
    
    [simpleCam closeWithCompletion:^{
        NSLog(@"SimpleCam is done closing ... ");
    }];
}

//View did load in SimpleCam VC
- (void) simpleCamDidLoadCameraIntoView:(CameraViewController *)simpleCam {
    NSLog(@"Camera loaded ... ");
    
    if (self.takePhotoImmediately) {
        [simpleCam capturePhoto];
    }
}



@end
