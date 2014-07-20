//
//  MRTextLayer.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "MRTextLayer.h"

@implementation MRTextLayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.1;
        self.textLabel.numberOfLines = 1;
        self.layer.mask = self.textLabel.layer;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.frame = self.bounds;
}

@end

