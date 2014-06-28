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

+ (UIColor *) edibleBlueColor_Deep {
    return [UIColor colorWithRed:51/255.0 green:119/255.0 blue:172/255.0 alpha:1];
}

@end
