//
//  ViewController.h
//  Edible
//
//  Created by Hao Zheng on 4/12/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CameraViewController.h"
#import <TesseractOCR/TesseractOCR.h>

@interface ViewController : UIViewController <SimpleCamDelegate,TesseractDelegate, UIActionSheetDelegate>

@end
