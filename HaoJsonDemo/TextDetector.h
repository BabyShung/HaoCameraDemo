//
//  TextDetector.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/23/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextDetector : NSObject
+(UIImage *)detectTextRegions:(UIImage *)orgImg;
@end
