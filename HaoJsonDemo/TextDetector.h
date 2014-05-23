//
//  TextDetector.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#include  "opencv2/opencv.hpp"
#include  "opencv2/objdetect.hpp"
#include  "opencv2/highgui.hpp"
#include  "opencv2/imgproc.hpp"
#include  "UIImage+OpenCV.h"

#include  <vector>

@interface TextDetector : NSObject
+(UIImage *) DetectTextRegions:(UIImage *)originImage;
@end
