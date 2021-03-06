//
//  GeneralControl.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralControl : NSObject

+(void)showErrorMsg:(NSString *)msg withTextField:(UITextField *)textfield;

+(void)transitionToVC:(UIViewController *)vc withToVCStoryboardId:(NSString*)name;

+(void)transitionToVC:(UIViewController *)vc withToVCStoryboardId:(NSString*)name withDuration:(CGFloat) duration;

+(void)enableBothCameraAndPageVCScroll:(BOOL)enable;

+(void)setPageViewControllerScrollEnabled:(BOOL)enabled;

+(void)updatingUI;

@end
