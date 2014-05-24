//
//  DebugViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "EParentViewController.h"
#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import <TesseractOCR/TesseractOCR.h>


@interface DebugViewController : EParentViewController <EdibleCameraDelegate,TesseractDelegate>

@end