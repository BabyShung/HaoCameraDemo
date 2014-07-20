//
//  LoadControls.m
//  EdibleCameraApp
//
//  Created by MEI C on 5/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LoadControls.h"
#import "ED_Color.h"
#import "HaoCaptureButton.h"


#define smallBTNRadius 25

#define ButtonAvailableAlpha 0.6

#define BUTTON_MARGIN_LEFT_RIGHT 10

#define BUTTON_MARGIN_DOWN 8

@implementation LoadControls


+(UIImage *) scaleImage:(UIImage *)image withScale:(CGFloat)scale withRect:(CGRect)rect andCropSize:(CGSize)size{
    
    //Crop View image, size is just the one on screen, CGImage is the original one
    // START CONTEXT
    //UIGraphicsBeginImageContext(size);
    UIImage *result;
    UIGraphicsBeginImageContextWithOptions(size, YES, scale);//this size is just cropView size,2.0 is for retina resolution !!!!!! important
    [image drawInRect:rect];
    result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // END CONTEXT
    return result;
}

+(UIImageView *)createImageViewWithRect:(CGRect)rect{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:rect];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    return imageView;
}

+(UILabel *)createLabelWithRect:(CGRect)rect andTextAlignment:(NSTextAlignment)ta andFont:(UIFont*)font andTextColor:(UIColor*)color{
    UILabel *label= [[UILabel alloc]initWithFrame:rect];
    label.text = @"";
    label.textAlignment = ta;
    label.font = font;
    label.textColor = color;
    label.backgroundColor = [UIColor clearColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    return label;
}

+(UITextView *)createTextViewWithRect:(CGRect)rect{
    UITextView *tv= [[UITextView alloc]initWithFrame:rect];
    tv.text = @"";
    tv.backgroundColor = [UIColor clearColor];
    //label.textAlignment = NSTextAlignmentCenter;
    //label.center = self.view.center;
    tv.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    return tv;
}

+(UIButton *)createUIButtonWithRect:(CGRect)rect{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"" forState:UIControlStateNormal];
    button.frame = rect;
    return button;
}

+(UIButton *)createRoundedBackButton{
    return [self createRoundedButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(8, 7, 8, 9) andLeftBottomElseRightBottom:YES];
}




+(UIButton *)createRoundedButton_Image:(NSString *)imageName andTintColor:(UIColor *) color andImageInset:(UIEdgeInsets) edgeInset andLeftBottomElseRightBottom:(BOOL)left{
    
    return [self createRoundedButton_Image:imageName andTintColor:color andImageInset:edgeInset andLeftBottomElseRightBottom:left andStartingPosition:CGPointZero];
}

+(UIButton *)createRoundedButton_Image:(NSString *)imageName andTintColor:(UIColor *) color andImageInset:(UIEdgeInsets) edgeInset andLeftBottomElseRightBottom:(BOOL)left andStartingPosition:(CGPoint)startingpoint{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.bounds = CGRectMake(0, 0, 50, 50);
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:.90];
    button.alpha = ButtonAvailableAlpha;
    
    if(imageName!=nil){
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setTintColor:color];
        [button setImageEdgeInsets:edgeInset];
    }
    
    CGFloat centerHeightToBottom = CGRectGetHeight([[UIScreen mainScreen] bounds])-button.bounds.size.height/2 -BUTTON_MARGIN_DOWN;
    
    if(CGPointEqualToPoint(CGPointZero, startingpoint)){
        if(left){
            button.center = CGPointMake(button.bounds.size.width/2 + BUTTON_MARGIN_LEFT_RIGHT, centerHeightToBottom);
        }else{
            button.center = CGPointMake(CGRectGetWidth([[UIScreen mainScreen] bounds]) - button.bounds.size.width/2 - BUTTON_MARGIN_LEFT_RIGHT, centerHeightToBottom);
        }
    }else{
        button.center = startingpoint;

    }
    
    

    
    button.layer.shouldRasterize = YES;
    button.layer.rasterizationScale = [UIScreen mainScreen].scale;
    button.layer.cornerRadius = smallBTNRadius;
    
    button.layer.borderColor = [ED_Color darkGreyColor].CGColor;
    button.layer.borderWidth = 0.5;
    return button;
}


+(UIButton *)createNiceCameraButton{
    NSDictionary *appearanceProxy1 = @{
                                       kMRoundedButtonCornerRadius : @4,
                                       kMRoundedButtonContentColor : [ED_Color edibleBlueColor_Deep],
                                       kMRoundedButtonContentAnimateToColor : [UIColor blackColor],
                                       kMRoundedButtonForegroundColor : [UIColor clearColor],
                                       kMRoundedButtonForegroundAnimateToColor : [[UIColor whiteColor] colorWithAlphaComponent:0.3]};
    [MRoundedButtonAppearanceManager registerAppearanceProxy:appearanceProxy1 forIdentifier:@"1"];
    
    CGRect buttonRect = CGRectMake(0,
                                   0,
                                   320,
                                   iPhone5?218:180);
    HaoCaptureButton *button = [[HaoCaptureButton alloc] initWithFrame:buttonRect
                                                       buttonStyle:MRoundedButtonImageWithSubtitle
                                              appearanceIdentifier:[NSString stringWithFormat:@"%d", 1]];
    button.center = CGPointMake(160, 300);
    
    button.backgroundColor = [UIColor clearColor];
    
    button.detailTextLabel.text = NSLocalizedString(@"CAPTURE_BTN", nil);
    button.detailTextLabel.font = [UIFont systemFontOfSize:16];
    button.imageView.image = [UIImage imageNamed:@"Camera_02.png"];
    
    return (UIButton *)button;
}



@end
