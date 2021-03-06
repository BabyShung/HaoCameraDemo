//
//  MainViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.


#import <TesseractOCR/TesseractOCR.h>
#import "CameraView.h"

/***********************************************
 
 Protocol, passing data back to FrameVC
 
 *********************************************/
@class MainViewController;
@class CameraView;

@protocol MainVCDelegate
@required
//debug
- (void) setCamDelegateFromMain:(MainViewController *)camVC;

//slide VC in PageViewController
- (void) slideToNextPage;

@end

@interface MainViewController : UICollectionViewController

@property (nonatomic,strong) CameraView* camView;

@property (retain, nonatomic) id <MainVCDelegate> Maindelegate;


@end
