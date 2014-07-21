//
//  LoadControls.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MRoundedButtonAppearanceManager.h"
#import "HaoCaptureButton.h"

@interface LoadControls : NSObject

//scale image
+(UIImage *) scaleImage:(UIImage *)image withScale:(CGFloat)scale withRect:(CGRect)rect andCropSize:(CGSize)size;

+(UIImageView *)createImageViewWithRect:(CGRect)rect;
+(UILabel *)createLabelWithRect:(CGRect)rect andTextAlignment:(NSTextAlignment)ta andFont:(UIFont*)font andTextColor:(UIColor*)color;
+(UITextView *)createTextViewWithRect:(CGRect)rect;

+(UIButton *)createRoundedBackButton;

+(UIButton *)createRoundedButton_Image:(NSString *)imageName andTintColor:(UIColor *) color andImageInset:(UIEdgeInsets) edgeInset andLeftBottomElseRightBottom:(BOOL)left;

+(UIButton *)createRoundedButton_Image:(NSString *)imageName andTintColor:(UIColor *) color andImageInset:(UIEdgeInsets) edgeInset andLeftBottomElseRightBottom:(BOOL)left andStartingPosition:(CGPoint)startingpoint;

+(UIButton *)createUIButtonWithRect:(CGRect)rect;
//camera button
+(HaoCaptureButton *)createNiceCameraButton_withCameraView:(UIView *)view;

@end
