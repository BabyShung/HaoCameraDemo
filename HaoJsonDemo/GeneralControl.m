//
//  GeneralControl.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "GeneralControl.h"
#import "AppDelegate.h"
#import "UIAlertView+Blocks.h"
#import "LocalizationSystem.h"

@implementation GeneralControl

+(void)enableBothCameraAndPageVCScroll:(BOOL)enable{
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(enable){
        [appDlg.cameraView resumeCamera];
        [self setPageViewControllerScrollEnabled:YES];
    }else{
        [appDlg.cameraView pauseCamera];
        [self setPageViewControllerScrollEnabled:NO];
    }
}

+(void)setPageViewControllerScrollEnabled:(BOOL)enabled{
    
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FrameViewController *fvc = appDlg.fvc;
    
    for(UIView* view in fvc.pageViewController.view.subviews){
        if([view isKindOfClass:[UIScrollView class]]){
            UIScrollView* scrollView=(UIScrollView*)view;
            if(enabled!=scrollView.scrollEnabled)
                [scrollView setScrollEnabled:enabled];
            return;
        }
    }
}

+(void)showErrorMsg:(NSString *)msg withTextField:(UITextField *)textfield{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AMLocalizedString(@"OOPS", nil) message:msg delegate:nil cancelButtonTitle:AMLocalizedString(@"Cancel", nil) otherButtonTitles: nil];
    [alert showWithHandler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if (buttonIndex == [alertView cancelButtonIndex]) {
            if(textfield){
                textfield.text = @"";
                [textfield becomeFirstResponder];
            }
        }
    }];
}

+(void)transitionToVC:(UIViewController *)vc withToVCStoryboardId:(NSString*)name{
    [self transitionToVC:vc withToVCStoryboardId:name withDuration:0.8];
}

+(void)transitionToVC:(UIViewController *)vc withToVCStoryboardId:(NSString*)name withDuration:(CGFloat) duration{
    UIWindow *windooo = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *fvc = [vc.storyboard instantiateViewControllerWithIdentifier:name];
    [UIView transitionWithView:windooo
                      duration:duration
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        vc.view.alpha = 0;
                    }
                    completion:^(BOOL success){
                        windooo.rootViewController = fvc;
                    }];
}

+(void)updatingUI{
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDlg.fvc updateAllViewControllers];
}

@end
