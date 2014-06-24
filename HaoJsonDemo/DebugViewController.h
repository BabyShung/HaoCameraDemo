//
//  DebugViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraView.h"
#import <TesseractOCR/TesseractOCR.h>

@class DebugViewController;

@protocol DebugVCDelegate

@required

- (void) getAllDetectedImages:(NSArray *) imageArray;


@end

@interface DebugViewController : UIViewController <EdibleCameraDelegate,TesseractDelegate>


@property (retain, nonatomic) id <DebugVCDelegate> debugDelegate;

@end
