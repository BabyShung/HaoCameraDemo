//
//  FoodInfoView.h
//  DetailViewDemo
//
//  Created by Hao Zheng on 6/21/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagView.h"
#import "FBShimmeringView.h"
#import "EDImageFlowLayout.h"
#import "RQShineLabel.h"
#import "Food.h"



@interface FoodInfoView : UIView

@property (nonatomic, strong) TagView *tagview;

@property (strong,nonatomic) UILabel *titleLabel;

@property (strong,nonatomic)UIView *separator;
@property (strong,nonatomic) UILabel *translateLabel;
@property (strong,nonatomic) FBShimmeringView *shimmeringView;

@property (strong,nonatomic) UIScrollView *scrollview;

@property (nonatomic, strong) EDImageFlowLayout *photoLayout;
@property (strong, nonatomic) UICollectionView *photoCollectionView;

@property (strong, nonatomic) RQShineLabel *descriptionLabel;

@property (strong,nonatomic) UITableView *commentsTableView;

@property (strong,nonatomic) Food *myFood;


- (id)initWithFrame:(CGRect)frame andVC:(UIViewController *)vc;

-(void)configPhotoAndTagWithCellNo:(NSInteger)no;

-(void)configCommentTable;

-(void)setVC:(UIViewController *)vc;

-(void)setUpForLargeLayout;

-(void)setUpForSmallLayout;

-(void)prepareForDisplayInCell:(NSInteger)cellNo;

-(void)prepareForDisplay;

-(void)shineDescription;

-(void)cleanUpForReuse;

-(void)resetData;
@end
