//
//  ED_Color.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/3/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "ED_Color.h"

@implementation ED_Color

#pragma mark COLORS

+ (UIColor *) darkGreyColor {
    return [UIColor colorWithRed:0.226082 green:0.244034 blue:0.297891 alpha:1];
}

+ (UIColor *) lightGrayColor {
    return [UIColor colorWithRed:199/255.0 green:199/255.0 blue:199/255.0 alpha:1];
}

+ (UIColor *) redColor {
    return [UIColor colorWithRed:1 green:0 blue:0.105670 alpha:.6];
}
+ (UIColor *) greenColor {
    return [UIColor colorWithRed:0.128085 green:.749103 blue:0.004684 alpha:0.6];
}
+ (UIColor *) blueColor {
    return [UIColor colorWithRed:0 green:.478431 blue:1 alpha:1];
}

+ (UIColor *) edibleBlueColor {
    return [UIColor colorWithRed:(46/255.0) green:(181/255.0) blue:(231/255.0) alpha:1];
}

+ (UIColor *) edibleBlueColor_Light {
    return [UIColor colorWithRed:(100/255.0) green:(212/255.0) blue:(252/255.0) alpha:1];
}

+ (UIColor *) edibleBlueColor_Deep {
    return [UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1];
}

+(UIColor *)edibleBlueColor_DeepDark{
    return [UIColor colorWithRed:0.161 green:0.502 blue:0.725 alpha:1.0];
}

+(UIColor *)edibleGreenColor{
    return [UIColor colorWithRed:69/255.0 green:164/255.0 blue:84/255.0 alpha:1];
}

+(UIColor *)cardLightBlue{
    return [UIColor colorWithRed:(0/255.0) green:(181/255.0) blue:(239/255.0) alpha:1];
}

+(UIColor *)cardLightGreen{
    return [UIColor colorWithRed:(150/255.0) green:(222/255.0) blue:(35/255.0) alpha:1];
}

+(UIColor *)cardLightYellow{
    return [UIColor colorWithRed:(255/255.0) green:(216/255.0) blue:(0/255.0) alpha:1];
}

+(UIColor *)cardMediumBlue{
    return [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(192/255.0) alpha:1];
}

+(UIColor *)cardDeepBrown{
    return [UIColor colorWithRed:(232/255.0) green:(119/255.0) blue:(36/255.0) alpha:1];
}

+(UIColor *)cardPink{
    return [UIColor colorWithRed:(253/255.0) green:(91/255.0) blue:(159/255.0) alpha:1];
}

@end
