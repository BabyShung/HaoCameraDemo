//
//  haoViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//


#import "CameraViewController.h"
#import "CameraView.h"

@implementation CameraViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.camView = [[CameraView alloc] initWithFrame:self.view.bounds andOrientation:self.interfaceOrientation andAppliedVC:self];
    [self.view addSubview:self.camView];
    
    
    //set camView delegate to be DEBUG_VC
    [self.delegate setCamDelegate:self];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    //Hao: important to change tabbar index
    [self.delegate checkTabbarStatus:self];
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.camView.StreamView.alpha = 1;
        self.camView.rotationCover.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([(NSObject *)self.camView.camDelegate respondsToSelector:@selector(EdibleCameraDidLoadCameraIntoView:)]) {
                [self.camView.camDelegate EdibleCameraDidLoadCameraIntoView:self];
            }
        }
    }];
}

@end
