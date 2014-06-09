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
#import "WordCorrector.h"
#import "LoadControls.h"

@interface DebugViewController ()

@property (weak, nonatomic) UIImageView *imageView1;
@property (weak, nonatomic) UIImageView *imageView2;
//@property (weak, nonatomic) UILabel *regLabel1;
//@property (weak, nonatomic) UILabel *regLabel2;
@property (weak, nonatomic) UITextView *regtv1;
@property (weak, nonatomic) UITextView *regtv2;

@property (strong,nonatomic) Tesseract *tesseract;

@property (strong,nonatomic) NSMutableArray *imgArray;

@property (strong,nonatomic) ImagePreProcessor *ipp;

@property (nonatomic) cv::Mat tempMat;

@end

@implementation DebugViewController


-(ImagePreProcessor*)ipp{
    if(!_ipp){
        _ipp = [[ImagePreProcessor alloc] init];
    }
    return  _ipp;
}

-(NSArray*) imgArray{
    if(!_imgArray){
        _imgArray = [[NSMutableArray alloc] init];
    }
    return  _imgArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_main_queue(), ^{});
    
    [self loadTesseract];
    
    [self initControls];
    
}

-(void)loadTesseract{
    _tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];//langague package
    _tesseract.delegate = self;
    [_tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()&/" forKey:@"tessedit_char_whitelist"]; //limit search
}


-(void)viewDidAppear:(BOOL)animated{
    [self.delegate checkTabbarStatus:self];
}

#pragma mark Tesseract
//tesseract processing
-(NSString *)recognizeImageWithTesseract:(UIImage *)img
{
    [_tesseract setImage:img]; //image to check
    [_tesseract recognize];//processing
    
    NSString *recognizedText = [_tesseract recognizedText];
    
    NSLog(@"Recognized: %@", recognizedText);
 
    return recognizedText;
}

- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    //NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

#pragma mark CAMERA DELEGATE

- (void) EdibleCamera:(MainViewController *)simpleCam didFinishWithImage:(UIImage *)image withRect:(CGRect)rect andCropSize:(CGSize)size{
    
    if (image) {
        /*****************************
         
         simple cam finished with image
         
         ****************************/

        
        //PS: image variable is the original size image (2448*3264)
        UIImage *onScreenImage = [self scaleImage:image withScale:1.5f withRect:rect andCropSize:size];
//        NSLog(@"on screen image(width):  %f",onScreenImage.size.width);
//        NSLog(@"on screen image(height):  %f",onScreenImage.size.height);
//
        UIImage *originalImage = [UIImage imageWithCGImage:onScreenImage.CGImage];
//        NSLog(@"original image(width):  %f",originalImage.size.width);
//        NSLog(@"original image(height):  %f",originalImage.size.height);

        CGSize cropSize = CGSizeMake(onScreenImage.size.width, onScreenImage.size.height);
        
        //original image, put in top imageview and get text in label
//        NSDate *methodStart = [NSDate date];
        
        
        [self placeImageInView:self.imageView1 withImage:originalImage withTextView:self.regtv1 andCGSize:cropSize];
        
//        NSDate *methodFinish = [NSDate date];
//        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
//        NSLog(@"<<<<<<<<<<1.5 Time = %f", executionTime);

        

        
        //------------------------------------- Charlie & Xinmei image pre processing field
        

//        // Step 1. Initiallize image pre processor
//        ImagePreProcessor *ipp = [[ImagePreProcessor alloc] init];
//        
//        // Step 2. convert photo image to cv Mat, where Mat is in 8UC4 format
//
//        cv::Mat tempMat= [originalImage CVMat];
//
//        // Step 3. put Mat into pre processor- Charlie
//        tempMat = [ipp processImage:tempMat];
//        
//        onScreenImage = [UIImage imageWithCVMat:tempMat];//convert back to uiimage

        // Step 4. put Mat into text Detector- Xinmei
        //NSMutableArray *locations = [[NSMutableArray alloc] init];
        NSDate *tdStart = [NSDate date];
        
        self.imgArray = [TextDetector detectTextRegions:originalImage];
        NSDate *tdFinish = [NSDate date];
        NSTimeInterval tdTime = [tdFinish timeIntervalSinceDate:tdStart];
        NSLog(@"<<<<<<<<<<1.5 tdTime = %f", tdTime);

        NSDate *ppStart = [NSDate date];
        if ([_imgArray count] > 0)
        {
    
        
            
            for(int i = 0; i<(self.imgArray.count-1);i++){
                
                
                //NSLog(@"***** %@",_imgArray[i]);
                // Charlie add image pre processing field
                
                // Step 1. Initiallize image pre processor
                //ImagePreProcessor *ipp = [[ImagePreProcessor alloc] init];
                
                // Step 2. convert photo image to cv Mat, where Mat is in 8UC4 format
                
                _tempMat= [self.imgArray[i] CVMat];
                
                // Step 3. put Mat into pre processor- Charlie
                _tempMat = [self.ipp processImage:_tempMat];
                
                self.imgArray[i] = [UIImage imageWithCVMat:_tempMat];//convert back to uiimage
                
                NSLog(@"2***** %@",_imgArray[i]);
                // End Pre Pro
                
            }
            NSDate *ppFinish = [NSDate date];
            NSTimeInterval ppTime = [ppFinish timeIntervalSinceDate:ppStart];
            NSLog(@"<<<<<<<<<<1.5 ppTime = %f", ppTime);
            
            //pass array to debugDelegate (VC3)
            [self.debugDelegate getAllDetectedImages:_imgArray];
            
            NSDate *trStart = [NSDate date];
            NSString *result = @"";
            for (int i = 0; i<_imgArray.count-1; i++) {
                NSString *tmp = [self recognizeImageWithTesseract:[_imgArray objectAtIndex:i]];
                result = [result stringByAppendingFormat:@"%d. %@\n",i, tmp];
                //            NSLog(@"tmp %d: %@",i, tmp);
            }
            NSDate *trFinish = [NSDate date];
            NSTimeInterval trTime = [trFinish timeIntervalSinceDate:trStart];
            NSLog(@"<<<<<<<<<<1.5 tesseractTime = %f", trTime);
            
            onScreenImage = [_imgArray objectAtIndex:(_imgArray.count-1)];
            NSLog(@"<<<<<<<<<<1.5 RESULT: \n%@", result);
            //self.regtv2.text = result;
            //------------------------------------- / End of pre pro
            [self placeImageInView:self.imageView2 withImage:onScreenImage withTextView:self.regtv2 andCGSize:cropSize];
            
            
            //precessed image, put in top imageview and get text in label
        }
        
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
-(void)placeImageInView:(UIImageView *)imageView withImage:(UIImage *)image withTextView:(UITextView *)tv andCGSize:(CGSize) size{
    imageView.image = image;
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y,
                                 size.width, size.height);
//    NSMutableArray *locations = [[NSMutableArray alloc] init];
//    
//    NSArray *imgArray = [[NSArray alloc]initWithArray:[TextDetector detectTextRegions:image]];
    
    
//    NSString *result = @"";
//    for (int i = 0; i<imgArray.count-1; i++) {
//        NSString *tmp = [self recognizeImageWithTesseract:[imgArray objectAtIndex:i]];
//        result = [result stringByAppendingFormat:@"%d. %@\n",i, tmp];
//        NSLog(@"tmp %d: %@",i, tmp);
//    }
//    NSLog(@"RESULT = %@", result);
//    tv.text = result;
//    imageView.image = [imgArray objectAtIndex:(imgArray.count-1)];
    
    
    tv.text = [self recognizeImageWithTesseract:image];
    
    //-----------Fang add word correction function here
    
    WordCorrector *wc = [[WordCorrector alloc]init];
    tv.text = [wc correctWord:tv.text];
    NSLog(@"This is it: %@",tv.text);
    //-----------/ End word correction
    
  

    
    dispatch_async(dispatch_get_main_queue(), ^{
        //2.save image to album
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    });
}

//View did load in SimpleCam VC
- (void) EdibleCameraDidLoadCameraIntoView:(MainViewController *)simpleCam {
    NSLog(@"Camera loaded ... ");

}

/***********
 
 Layouts
 
 *********/

-(void)initControls{
    
    LoadControls *lc = [[LoadControls alloc]init];
    
    float topX = 40;
    float topH = 120;
    float topW = 320;
    
    float textViewHeight = 100;
    
    //add debug views
    self.imageView1 = [lc createImageViewWithRect:CGRectMake(0, topX, topW, topH)];
    self.imageView2 = [lc createImageViewWithRect:CGRectMake(0, topX + topH + topH, topW, topH)];
    self.regtv1 = [lc createTextViewWithRect:CGRectMake(0, topX + topH, topW, textViewHeight)];
    self.regtv2 = [lc createTextViewWithRect:CGRectMake(0, topX + topH * 3, topW, textViewHeight)];
    
    [self.view addSubview:self.imageView1];
    [self.view addSubview:self.imageView2];
    [self.view addSubview:self.regtv1];
    [self.view addSubview:self.regtv2];
    
}

-(UIImage *) scaleImage:(UIImage *)image withScale:(CGFloat)scale withRect:(CGRect)rect andCropSize:(CGSize)size{

    //Crop View image, size is just the one on screen, CGImage is the original one
    // START CONTEXT
    //UIGraphicsBeginImageContext(size);
    UIImage *result;
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);//this size is just cropView size,2.0 is for retina resolution !!!!!! important
    [image drawInRect:rect];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // END CONTEXT
    return result;
}

@end
