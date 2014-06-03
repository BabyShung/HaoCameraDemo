//
//  TextDetector.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
bool compareLoc(const cv::Rect &a, const cv::Rect &b);
}

#endif

@interface TextDetector : NSObject
//Return UIImages of text Regions AND a UIImage with its text regions marked as the last object in the array
+(NSMutableArray *)detectTextRegions:(UIImage *)orgImg;

//Return UIImages of text Regions AND their Locations IN ORDER
//locaitons array must be initialzed before passed in, throw an exception otherwise
+(NSArray *)UIImagesOfTextRegions:(UIImage *)orgImg withLocations:(NSMutableArray *)locations;

@end
