//
//  TextDetector.m
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "TextDetector.h"
#include <vector>
#import <opencv2/opencv.hpp>
#include "UIImage+OpenCV.h"

using namespace cv;
using namespace std;


@implementation TextDetector
+(UIImage *)detectTextRegions:(UIImage *)orgImg{
    
    cv::Mat orgMat = [orgImg CVMat];
    NSLog(@"Function called!");
    UIImage *result;
    return result;
}
@end
