//
//  TextDetector.m
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "TextDetector.h"

using namespace cv;
using namespace std;

@implementation TextDetector
+(UIImage *) DetectTextRegions:(UIImage *)originImage{
    
    UIImage *resultImage;
    
    Mat originMat = [originImage CVMat];
    vector<int> intvec;
    intvec.push_back(1);
    NSLog(@"no = %lu",intvec.size()/sizeof(int));
    
    return resultImage;
}
@end
