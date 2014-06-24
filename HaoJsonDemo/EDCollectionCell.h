//
//  EDCollectionCell.h
//  Paper
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodInfoView.h"
@interface EDCollectionCell : UICollectionViewCell

@property (strong,nonatomic) FoodInfoView *foodInfoView;

//This function must be called before large layout cells appear
-(void)setVCForFoodInfoView:(UIViewController *)vc;

@end
