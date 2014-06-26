//
//  LoadControls.m
//  EdibleCameraApp
//
//  Created by MEI C on 5/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LoadControls.h"

#define ButtonAvailableAlpha 0.6

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

+(UIButton *)createCameraButton_Image:(NSString *)imageName andTintColor:(UIColor *) color andImageInset:(UIEdgeInsets) edgeInset andCenter:(CGPoint)center{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];

    button.bounds = CGRectMake(0, 0, 40, 40);
    button.backgroundColor = [UIColor colorWithWhite:1 alpha:.90];
    button.alpha = ButtonAvailableAlpha;
    
    if(imageName!=nil){
        [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [button setTintColor:color];
        [button setImageEdgeInsets:edgeInset];
        
    }
    
    if(!CGPointEqualToPoint(center,CGPointZero)){
        button.center = center;
        NSLog(@"goes here1");
    }


    
    button.layer.shouldRasterize = YES;
    button.layer.rasterizationScale = [UIScreen mainScreen].scale;
    button.layer.cornerRadius = 4;
    
    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.borderWidth = 0.5;
    return button;
}



@end
