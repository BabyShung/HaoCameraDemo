//
//  ImagePreProcessor.m
//  TestGray
//
//  Created by CharlieGao on 5/22/14.
//  Copyright (c) 2014 Edible Innovations. All rights reserved.
//

#import "ImagePreProcessor.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"

@implementation ImagePreProcessor


-(cv::Mat)toGrayMat:(UIImage *) inputImage{
    
    cv::Mat matImage = [inputImage CVGrayscaleMat];
    return matImage;
}

-(cv::Mat)to8UC4Mat:(UIImage *) inputImage{
    
    cv::Mat matImage = [inputImage CVMat];
    return matImage;
}

-(UIImage *)toGrayUIImage:(cv::Mat) inputMat{

    UIImage *img = [[UIImage alloc] init];
    img = [UIImage imageWithCVMat:inputMat];
    return img;
}


-(cv::Mat)threadholdControl:(cv::Mat) inputImage{
    
    cv::Mat output;
    cv::adaptiveThreshold(inputImage, output, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
    return output;

}

-(cv::Mat)gaussianBlur:(cv::Mat)inputImage :(int)h :(int)w{
    
    cv::Mat output;
    cv::Size size;
	size.height = h;
	size.width = w;
    cv::GaussianBlur(inputImage, output, size, 0.8);
    return output;

}

-(cv::Mat)laplacian:(cv::Mat)inputImage{
    
    cv::Mat output;
    cv::Mat kernel = (cv::Mat_<float>(3, 3) << 0, -1, 0, -1, 5, -1, 0, -1, 0); //Laplacian operator
    cv::filter2D(inputImage, output, output.depth(), kernel);
    return output;

}

-(cv::Mat)removeBackgroud:(cv::Mat)inputImage{
    
    cv::Size size;
	size.height = 3;
	size.width = 3;
    inputImage = [self laplacian:inputImage];
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
	//cv::adaptiveThreshold(inputImage, inputImage, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 25, 14);
    cv::threshold(inputImage, inputImage, 125,255, cv::THRESH_TRUNC);
	cv::GaussianBlur(inputImage, inputImage, size, 0.8);
    inputImage = [self laplacian:inputImage];
    return inputImage;
}

-(cv::Mat)sharpen:(cv::Mat)inputImage{
    cv::Mat output;
    cv::GaussianBlur(inputImage, output, cv::Size(0, 0), 10);
    cv::addWeighted(inputImage, 1.5, output, -0.5, 0, output);
    return output;
}

-(cv::Mat)erosion:(cv::Mat)inputImage{
    
    
    int erosion_size = 1;

    cv::Mat element = cv::getStructuringElement( cv::MORPH_CROSS,
                                                cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                                cv::Point( erosion_size, erosion_size ) );
    
    /// Apply the erosion operation
    cv::erode( inputImage, inputImage, element );
    return inputImage;
}


-(cv::Mat)processImage: (cv::Mat)inputImage{
    // this function check the input image's style : black+white or white+black
    cv::Mat output;
    int isBlackBack = 0; //default setting
    isBlackBack = [self checkBackground:inputImage];
    if (isBlackBack == 1) {
        
        output = [self sharpen:inputImage];
        output = [self laplacian:output];
        NSLog(@"Menu catch: Black back ground\n");
    }
    else{
        
        //output = [self sharpen:output];
        output = [self removeBackgroud:inputImage];
        output = [self sharpen:output];
        NSLog(@"Menu catch: White back ground\n");
        
    }
    
    return output;
}


-(int)checkBackground:(cv::Mat )input //Fang's
{
    int rows = input.rows;
    int cols = input.cols;
    
    //count the sum of the pixl
    int sum_pixl = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            uchar pixl = input.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            sum_pixl = sum_pixl + pixl_int;
        }
    }
    //count the average of the pixel
    int ave_pixl = sum_pixl/(rows*cols);
    //count_white the nuber of pixl whose value is bigger than average
    int count_white = 0;
    //count_white the nuber of pixl whose value is smaller than average
    int count_black = 0;
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            
            uchar pixl = input.at<uchar>(i,j);
            int pixl_int = pixl - '0';
            if (pixl_int>=ave_pixl) {
                count_white= count_white+1;
            }else{
                count_black = count_black +1;
            }
            
        }
    }
    //if more white then Black background（0） others （1）
    if (count_black <= count_white) {
        return 0;
    } else {
        return 1;
    }
    
}












@end
