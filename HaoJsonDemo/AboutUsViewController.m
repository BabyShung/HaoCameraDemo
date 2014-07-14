//
//  AboutUsViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/10/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AboutUsViewController.h"
#import "LoadControls.h"
#import "ED_Color.h"
#import "AppDelegate.h"

@interface AboutUsViewController ()

@property (strong, nonatomic) UIButton *backBtn;

@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _backBtn = [LoadControls createRoundedButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andLeftBottomElseRightBottom:YES];
    [_backBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    //also stop camera
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDlg.cameraView pauseCamera];
    
    
    self.textView.text = NSLocalizedString(@"ABOUT_US", nil);
    
}

- (void) previousPagePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    //also resume camera
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDlg.cameraView resumeCamera];
}


@end
