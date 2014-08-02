//
//  EDImageCell.m
//  DetailViewDemo
//
//  Created by Hao Zheng on 6/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "EDImageCell.h"
#import "LoadControls.h"

@interface EDImageCell ()

@end

@implementation EDImageCell

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //self.backgroundColor = [UIColor grayColor];
        
        //add imageView
        self.imageView = [LoadControls createImageViewWithRect:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        [self.contentView addSubview:self.imageView];
        
        //add indicator
        self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.center=self.contentView.center;
        [self.contentView addSubview:self.activityView];
    }
    return self;
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    
    //[self.imageView cancelLoadingAllImagesAndLoaderName:self.imgLoaderName];
    self.imageView.image = nil;
}

@end
