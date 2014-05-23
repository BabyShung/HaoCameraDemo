//
//  ViewController.m
//  Edible
//
//  Created by Hao Zheng on 4/12/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "ViewController.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import "ImagePreProcessor.h"

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
    
    UIImage *testCV = [UIImage imageNamed:@"portrait_Preview.png"];
    
    cv:: Mat tempMat = [testCV CVMat];
    cv::Size size;
    size.height = 3;
    size.width = 3;
    
    //cv::Canny(tempMat, tempMat, 0.8, 0.5);
    testCV = [UIImage imageWithCVMat:tempMat];
    
    [self initControls];

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


#pragma mark take photo
- (void)actionPhoto{
    [self.CameraVC capturePhoto];
}

#pragma mark TAP RECOGNIZER

- (void) handleTap:(UITapGestureRecognizer *)tap {
    
    CameraViewController * simpleCam = [CameraViewController new];
    simpleCam.delegate= self;
    //simpleCam.isCropMode = YES;
    [self presentViewController:simpleCam animated:YES completion:nil];
}

#pragma mark CAMERA DELEGATE

- (void) EdibleCamera:(CameraViewController *)simpleCam didFinishWithImage:(UIImage *)image {
    
    if (image) {
        /*****************************
         
         simple cam finished with image
         
        ****************************/
        
        
        //------------------------------------- Charlie add image pre processing
        
        
        //ImagePreProcessor *ipp = [[ImagePreProcessor alloc] init];
        //cv::Mat tempMat= [ipp toGrayMat:image];
        
        //tempMat = [ipp threadholdControl:tempMat];//change here to change filter
        //tempMat = [ipp erode:tempMat];
        //tempMat = [ipp dilate:tempMat];//change here to change filter
        
        //image =[ipp toGrayUIImage:tempMat];
        
        
        
        //------------------------------------- / End of pre pro
        
        
        
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
- (void) EdibleCameraDidLoadCameraIntoView:(CameraViewController *)simpleCam {
    NSLog(@"Camera loaded ... ");
    
    if (self.takePhotoImmediately) {
        [simpleCam capturePhoto];
    }
}

-(void)initControls{
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

@end
