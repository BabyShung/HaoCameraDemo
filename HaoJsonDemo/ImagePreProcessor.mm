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

-(cv::Mat)removeBackground:(cv::Mat)inputImage{
    
    cv::Size size;
	size.height = 3;
	size.width = 3;
    //inputImage = [self laplacian:inputImage];
    cv::cvtColor(inputImage,inputImage,cv::COLOR_BGR2GRAY);
    cv::GaussianBlur(inputImage, inputImage, size, 0.8);
	cv::adaptiveThreshold(inputImage, inputImage, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C, cv::THRESH_BINARY, 11, 2);
    //cv::threshold(inputImage, inputImage, 125,255, cv::THRESH_TRUNC);
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
    //isBlackBack = [self checkBackground:inputImage];
    if (isBlackBack == 1) {
        
        output = [self sharpen:inputImage];
        output = [self laplacian:output];
        NSLog(@"Menu catch: Black back ground\n");
    }
    else{
        
        //output = [self sharpen:output];
        output = [self removeBackground:inputImage];
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


//-------below is remove back ground version 2  stable version

-(cv::Mat)CalcBlockMeanVariance:(cv::Mat) Img : (float) blockSide

// blockSide - the parameter (set greater for larger font on image)
{
    cv::Mat I;
    
    
    Img.convertTo(I,CV_32FC1);
    cv::Mat Res;
    Res=cv::Mat::zeros(Img.rows/blockSide,Img.cols/blockSide,CV_32FC1);
    cv::Mat inpaintmask;
    cv::Mat patch;
    cv::Mat smallImg;
    
    cv::Scalar m,s;
    
    blockSide =21;
    
    for(int i=0;i<Img.rows-blockSide;i+=blockSide)
    {
        for (int j=0;j<Img.cols-blockSide;j+=blockSide)
        {
            patch=I(cv::Range(i,i+blockSide+1),cv::Range(j,j+blockSide+1));
            cv::meanStdDev(patch,m,s);
            if(s[0]>0.01) // Thresholding parameter (set smaller for lower contrast image)
            {
                Res.at<float>(i/blockSide,j/blockSide)=m[0];
            }else
            {
                Res.at<float>(i/blockSide,j/blockSide)=0;
            }
        }
    }
    
    cv::resize(I,smallImg,Res.size());
    
    cv::threshold(Res,inpaintmask,0.02,1.0,cv::THRESH_BINARY);
    
    cv::Mat inpainted;
    smallImg.convertTo(smallImg,CV_8UC1,255);
    
    inpaintmask.convertTo(inpaintmask,CV_8UC1);
    
    cv::inpaint(smallImg, inpaintmask, inpainted, 5, cv::INPAINT_TELEA);
    
    cv::resize(inpainted,Res,Img.size());
    Res.convertTo(Res,CV_32FC1,1.0/255.0);
    return Res;
}


-(cv::Mat)removeBackground2:(cv::Mat) inputMat
{
    cv::Mat Img,res;
    cv::cvtColor(inputMat,Img,cv::COLOR_RGB2GRAY);
    
    
    
    Img.convertTo(Img,CV_8UC4);
    
    
    Img.convertTo(Img,CV_32FC1,1.0/255.0);
    
    
    
    
    res = [self CalcBlockMeanVariance:Img:21];
    res=1.0-res;
    res=Img+res;
    
    
    cv::threshold(res,res,0.85,1,cv::THRESH_BINARY);
    
    res.convertTo(res, CV_8UC4,255);
    
    return res;
}

//-------/remove back ground v2















@end
