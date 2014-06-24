//
//  MainViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.

#import "CameraView.h"

/***********************************************
 
 Protocol, passing data back to FrameVC
 
 *********************************************/
@class MainViewController;
@class CameraView;


@protocol MainVCDelegate

@required

- (void) checkTabbarStatus:(UIViewController *) vc;

//for debug
- (void) moveToTabFromMainVC:(NSUInteger) index;


//debug
- (void) setCamDelegateFromMain:(MainViewController *)camVC;

@end

@interface MainViewController : UICollectionViewController

@property (nonatomic,strong) CameraView* camView;

@property (retain, nonatomic) id <MainVCDelegate> Maindelegate;

-(void)addItem;

@end
