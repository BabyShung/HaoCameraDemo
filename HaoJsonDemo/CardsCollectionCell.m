//
//  DECollectionViewCell.m
//  MyPolicyCard
//
//  Created by Hao Zheng on 6/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "CardsCollectionCell.h"
#import "LoadControls.h"
@interface CardsCollectionCell ()


@end

@implementation CardsCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        
        //init titleLabel
        self.titleLabel = [LoadControls createLabelWithRect:CGRectMake(10, 10, CGRectGetWidth( frame)-20, 100) andTextAlignment:NSTextAlignmentCenter andFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:20] andTextColor:[UIColor colorWithRed:(48/255.0) green:(56/255.0) blue:(57/255.0) alpha:1]];
        [self.contentView addSubview:self.titleLabel];
        
        
        self.layer.cornerRadius = 8;

        
    }
    return self;
}

-(void)setImageView:(UIImageView *)imageView {
    _imageView = imageView;
    _imageView.frame = self.bounds;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _imageView.layer.cornerRadius = 10.f;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
}


@end