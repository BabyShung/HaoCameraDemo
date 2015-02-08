//
//  DNUtils.m
//  Blue Cheese
//
//  Created by Yang Wan on 26/01/2015.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import "DNUtils.h"

#define DEBUG_MODE NO


@implementation DNUtils


+ (void) giveMeABorder:(UIView *) view withColor:(UIColor *)color
{
    if(DEBUG_MODE){
        //    view.backgroundColor = [UIColor clearColor];
        if (!color) {
            color = [UIColor redColor];
        }
        
        view.layer.borderColor = color.CGColor;
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 5;
        view.layer.masksToBounds = YES;
    }
    
}
+ (void) giveMeBorders:(UIView *) view withColor:(UIColor *)color
{
    if(DEBUG_MODE){
        if (!color) {
            color = [UIColor blackColor];
        }
        
        view.layer.borderColor = color.CGColor;
        view.layer.borderWidth = 1.0;
        view.layer.cornerRadius = 5;
        view.layer.masksToBounds = YES;
        
        NSArray *subViews = [view subviews];
        // for subViews
        if (subViews) {
            for (UIView *v in subViews) {
                [self giveMeBorders:v withColor:nil];
            }
        }
    }
    
}


@end
