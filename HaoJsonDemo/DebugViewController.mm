//
//  DebugViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "DebugViewController.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import "ImagePreProcessor.h"
#import "TextDetector.h"


@interface DebugViewController ()

@property (weak, nonatomic) UIImageView *imageView1;
@property (weak, nonatomic) UIImageView *imageView2;
//@property (weak, nonatomic) UILabel *regLabel1;
//@property (weak, nonatomic) UILabel *regLabel2;
@property (weak, nonatomic) UITextView *regtv1;
@property (weak, nonatomic) UITextView *regtv2;


@end

@implementation DebugViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{});
    
    
    [self initControls];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self.delegate checkTabbarStatus:self.pageIndex];
}

#pragma mark Tesseract
//tesseract processing
-(NSString *)recognizeImageWithTesseract:(UIImage *)img
{
    Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:@"eng+ita"];//langague package
    tesseract.delegate = self;
    [tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()&/" forKey:@"tessedit_char_whitelist"]; //limit search
    
    
    [tesseract setImage:img]; //image to check
    [tesseract recognize];//processing
    
    NSString *recognizedText = [tesseract recognizedText];
    NSLog(@"Recognized: %@", recognizedText);
    
    tesseract = nil; //deallocate and free all memory *****
    
    return recognizedText;
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    //NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark CAMERA DELEGATE

- (void) EdibleCamera:(CameraViewController *)simpleCam didFinishWithImage:(UIImage *)image {
    
    if (image) {
        /*****************************
         
         simple cam finished with image
         
         ****************************/
        
        
        //original image, put in top imageview and get text in label
        [self placeImageInView:self.imageView1 withImage:image withTextView:self.regtv1];
        
        
        
        
        //------------------------------------- Charlie & Xinmei image pre processing field
        
        // Step 1. Initiallize image pre processor
        ImagePreProcessor *ipp = [[ImagePreProcessor alloc] init];
        
        // Step 2. convert photo image to cv Mat, where Mat is in 8UC4 format
        cv::Mat tempMat= [image CVMat];
        
        // Step 3. put Mat into pre processor- Charlie
        tempMat = [ipp processImage:tempMat];
        //tempMat = [ipp removeBackground2:tempMat];
        image = [UIImage imageWithCVMat:tempMat];//convert to uiimage
        
        // Step 4. put Mat into text Detector- Xinmei
        //image = [TextDetector detectTextRegions:image];
        
        
        //------------------------------------- / End of pre pro
        
        
        
        //precessed image, put in top imageview and get text in label
        [self placeImageInView:self.imageView2 withImage:image withTextView:self.regtv2];
        
        
    }else {// simple cam finished w/o image
        self.imageView1.image = nil;
        self.imageView2.image = nil;
    }
    
    /*****************************
     
     Close Camera -
     use this as opposed to 'dismissViewController' otherwise,
     the captureSession may not close properly and may result in memory leaks.
     
     *********************************/

//******* PS: not needed since added pageViewController, need to think about AVCaptureSession problem about memory and resources
//    [simpleCam closeWithCompletion:^{
//        NSLog(@"SimpleCam is done closing ... ");
//    }];
    
    
    NSLog(@"****************** PHOTO TAKEN ********************");
}


//helper for viewing
-(void)placeImageInView:(UIImageView *)imageView withImage:(UIImage *)image withTextView:(UITextView *)tv{
    imageView.image = image;
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,
                                 image.size.width, image.size.height);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //1.Use tesseract to recognize image
        tv.text = [self recognizeImageWithTesseract:image];
        
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //2.save image to album
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    });
}

//View did load in SimpleCam VC
- (void) EdibleCameraDidLoadCameraIntoView:(CameraViewController *)simpleCam {
    NSLog(@"Camera loaded ... ");

}

/***********
 
 Layouts
 
 *********/

-(void)initControls{
    
    float topX = 40;
    float topH = 120;
    float topW = 320;
    
    float textViewHeight = 100;
    
    //add debug views
    self.imageView1 = [self createImageViewWithRect:CGRectMake(0, topX, topW, topH)];
    self.imageView2 = [self createImageViewWithRect:CGRectMake(0, topX + topH + topH, topW, topH)];
    self.regtv1 = [self createTextViewWithRect:CGRectMake(0, topX + topH, topW, textViewHeight)];
    self.regtv2 = [self createTextViewWithRect:CGRectMake(0, topX + topH * 3, topW, textViewHeight)];
}

-(UIImageView *)createImageViewWithRect:(CGRect)rect{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    //imageView.bounds = CGRectMake(0, 0, 320, 568);
    //imageView.bounds = rect;
    //imageView.center = self.view.center;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    return imageView;
}

-(UILabel *)createLabelWithRect:(CGRect)rect{
    UILabel *label= [[UILabel alloc]initWithFrame:rect];
    label.text = @"";
    //label.textAlignment = NSTextAlignmentCenter;
    //label.center = self.view.center;
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:label];
    return label;
}

-(UITextView *)createTextViewWithRect:(CGRect)rect{
    UITextView *tv= [[UITextView alloc]initWithFrame:rect];
    tv.text = @"";
    tv.backgroundColor = [UIColor clearColor];
    //label.textAlignment = NSTextAlignmentCenter;
    //label.center = self.view.center;
    tv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.view addSubview:tv];
    return tv;
}


@end
