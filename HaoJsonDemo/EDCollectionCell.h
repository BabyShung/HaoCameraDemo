//
//  EDCollectionCell.h
//  Paper
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBShimmering.h"
#import "FBShimmeringView.h"
@interface EDCollectionCell : UICollectionViewCell

@property (strong,nonatomic) FBShimmeringView *shimmeringView;

@property (strong,nonatomic) UILabel *titleLabel;

@end
