//
//  ImagePreProcessor.h
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef struct{
    int contador;
    double media;
} cuadrante;




@interface ImagePreProcessor : UIImage

-(cv::Mat)toGrayMat:(UIImage *) inputImage;

-(cv::Mat)threadholdControl:(cv::Mat) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w; // size.height size.weight

-(cv::Mat)laplacian:(cv::Mat) inputImage;

-(UIImage *)deBlur:(UIImage *) inputimage;

-(IplImage *)CreateIplImageFromUIImage:(UIImage *)image;

-(UIImage *)UIImageFromIplImage:(IplImage *)image;

-(UIImage *)toGrayUIImage:(cv::Mat) inputMat;

-(cv::Mat)removeBackgroud:(cv::Mat)inputImage;


//Fang
-(cv::Mat)canny:(cv::Mat)input;

-(cv::Mat)bilateralFilter:(cv::Mat)input;

-(cv::Mat)boxFilter:(cv::Mat)input;

-(cv::Mat)erode:(cv::Mat)input;

-(cv::Mat)dilate:(cv::Mat)input;

-(cv::Mat)laplacian2:(cv::Mat)input;



// Referrencing ANPR Image Processor.cpp


-(cv::Mat)filterMedianSmoot:(cv::Mat)source;
-(cv::Mat) filterGaussian:(cv::Mat)source;
-(cv::Mat)equalize:(cv::Mat)source;
-(cv::Mat) binarize:(cv::Mat)source;
-(int) correctRotation: (cv::Mat) image :(cv::Mat) output :(float) height;
-(cv::Mat) rotateImage:(cv::Mat) source :(double) angle;


- (cv::Mat)processImage:(cv::Mat)src;

@end
