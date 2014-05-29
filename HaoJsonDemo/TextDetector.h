//
//  TextDetector.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
//#include <vector>

#ifdef __cplusplus
extern "C" {
bool compareLoc(const cv::Rect &a, const cv::Rect &b);
}

#endif

@interface TextDetector : NSObject
+(UIImage *)detectTextRegions:(UIImage *)orgImg;
//+(NSArray *)UIImagesOfTextRegions:(UIImage *)orgImg withLocations:(std::vector<cv::Rect> &) rects;

@end
