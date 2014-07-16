//
//  ED_Color.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/3/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ED_Color : NSObject

+ (UIColor *) darkGreyColor;
+ (UIColor *) lightGrayColor;
+ (UIColor *) redColor;
+ (UIColor *) greenColor;
+ (UIColor *) blueColor;

+ (UIColor *) edibleBlueColor;
+ (UIColor *) edibleBlueColor_Light;
+ (UIColor *) edibleBlueColor_Deep;
+ (UIColor *)edibleBlueColor_DeepDark;

+ (UIColor *)edibleGreenColor;

+ (UIColor *)cardLightBlue;
+ (UIColor *)cardLightGreen;
+ (UIColor *)cardLightYellow;
+ (UIColor *)cardMediumBlue;
+ (UIColor *)cardDeepBrown;
+ (UIColor *)cardPink;

@end
