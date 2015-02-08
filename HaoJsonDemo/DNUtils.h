//
//  DNUtils.h
//  Blue Cheese
//
//  Created by Yang Wan on 26/01/2015.
//  Copyright (c) 2015 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define bottomOffset 68 // the collection view (cells) bottom offset, by Yang WAN

@interface DNUtils : NSObject

+ (void) giveMeABorder:(UIView *) view withColor:(UIColor *)color;

+ (void) giveMeBorders:(UIView *) view withColor:(UIColor *)color;


@end
