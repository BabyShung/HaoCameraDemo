//
//  MRImageLayer.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "MRImageLayer.h"

@implementation MRImageLayer

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        //self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Camera_01.png"]];
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor clearColor];
        self.layer.mask = self.imageView.layer;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    //self.imageView.center = self.center;
}

@end

