//
//  haoViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EParentViewController.h"


@class CameraView;

@interface CameraViewController : EParentViewController 

@property (nonatomic,strong) CameraView* camView;

@end
