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

-(cv::Mat)to8UC4Mat:(UIImage *) inputImage;

-(cv::Mat)threadholdControl:(cv::Mat) inputImage;

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w; // size.height size.weight

-(cv::Mat)laplacian:(cv::Mat) inputImage;


-(IplImage *)CreateIplImageFromUIImage:(UIImage *)image;

-(UIImage *)UIImageFromIplImage:(IplImage *)image;

-(UIImage *)toGrayUIImage:(cv::Mat) inputMat;

-(cv::Mat)removeBackgroud:(cv::Mat)inputImage;

-(cv::Mat)processImage: (cv::Mat)inputImage;

-(int)checkBackground:(cv::Mat)input;









@end
