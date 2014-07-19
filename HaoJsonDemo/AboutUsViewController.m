//
//  AboutUsViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/10/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AboutUsViewController.h"
#import "LoadControls.h"
#import "LocalizationSystem.h"
#import "GeneralControl.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton *btn = [LoadControls createRoundedBackButton];
    [btn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.textView.text = AMLocalizedString(@"ABOUT_US", nil);
    
}

- (void) previousPagePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
