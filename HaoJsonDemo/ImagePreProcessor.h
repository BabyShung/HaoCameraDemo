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

-(cv::Mat)removeBackground:(cv::Mat)inputImage;

-(cv::Mat)processImage: (cv::Mat)inputImage;

-(int)checkBackground:(cv::Mat)input;

-(cv::Mat)CalcBlockMeanVariance:(cv::Mat) Img : (float) blockSide;

-(cv::Mat)removeBackground2:(cv::Mat) inputMat;





@end
