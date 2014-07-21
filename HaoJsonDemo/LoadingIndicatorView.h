//
//  LoadingIndicatorView.h
//  EdibleCameraApp
//
//  Created by MEI C on 7/14/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "LocalizationSystem.h"

@protocol LoadingIndicatorViewDelegate <NSObject>
@required
-(void) LoadingIndicatorFireReLoad;

@end

@interface LoadingIndicatorView : UIView

@property (nonatomic, assign) id<LoadingIndicatorViewDelegate> delegate;

@property (strong,nonatomic) UIButton *loadingBtn;

@property (nonatomic,readonly) BOOL isLoading;

@property (nonatomic,readonly) BOOL isFailed;

@property (nonatomic,readonly) BOOL shouldBeHidden;

-(void)showLoadingMsg;

-(void)showFailureMsg;

-(void)hide;

@end
