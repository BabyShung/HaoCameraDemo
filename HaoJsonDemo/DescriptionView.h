//
//  DescriptionView.h
//  EdibleCameraApp
//
//  Created by MEI C on 7/21/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocalizationSystem.h"

@protocol DescriptionViewDelegate <NSObject>

//Content text change fires this delegate
//Content text change results in frame change
@required -(void) DesciprionViewTextDidChanged;

//Press Readmore btn fires this delegate
//Result in frame change
@required -(void) DesciprionViewReadMoreFired;

@end

@interface DescriptionView : UIView

@property (nonatomic, assign) id<DescriptionViewDelegate> delegate;

@property (strong, nonatomic, getter = getContentText, setter = setContentText:) NSString *contentText;

@property (strong, nonatomic) UIButton *readMoreBtn;

@property (strong, nonatomic) UIButton *transparentBtn;

//Used to caculate the required height for displaying complete content text
//It is screen width by default
@property (nonatomic,assign) CGFloat boundedContentWidth;

-(void)shine;

-(void)config;

-(void)resetData;

@end
