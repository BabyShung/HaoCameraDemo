//
//  AppDelegate.h
//  HaoJsonDemo
//
//  Created by Hao Zheng on 4/12/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CameraView.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) CameraView *cameraView;



-(CameraView *)getCamView;

@end
