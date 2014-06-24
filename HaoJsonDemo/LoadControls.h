//
//  LoadControls.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadControls : NSObject

+(UIImageView *)createImageViewWithRect:(CGRect)rect;
+(UILabel *)createLabelWithRect:(CGRect)rect andTextAlignment:(NSTextAlignment)ta andFont:(UIFont*)font andTextColor:(UIColor*)color;
+(UITextView *)createTextViewWithRect:(CGRect)rect;


+(UIButton *)createCameraButton_Image:(NSString *)imageName andTintColor:(UIColor *) color andImageInset:(UIEdgeInsets) edgeInset andCenter:(CGPoint)center;
@end
