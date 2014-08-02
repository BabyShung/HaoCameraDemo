//
//  FoodInfoView.h
//  DetailViewDemo
//
//  Created by Hao Zheng on 6/21/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "TagView.h"
#import "EDImageFlowLayout.h"
#import "RQShineLabel.h"
#import "Food.h"
#import "Comment.h"
#import "UIView+Toast.h"
#import "EDCommentView.h"
#import "LoadingIndicatorView.h"
#import "DescriptionView.h"

@interface FoodInfoView : UIView

//components
@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) UILabel *translateLabel;
@property (strong,nonatomic) UIImageView *starImgView;
@property (strong,nonatomic) UILabel *starNumberLabel;
@property (strong,nonatomic) DescriptionView *descripView;

@property (nonatomic, strong) TagView *tagview;

@property (nonatomic, strong) EDImageFlowLayout *photoLayout;
@property (strong, nonatomic) UICollectionView *photoCollectionView;

@property (strong,nonatomic)UIView *separator;
@property (strong,nonatomic) UIScrollView *scrollview;
@property (strong,nonatomic) UITableView *commentsTableView;

@property (strong, nonatomic) UIButton * commentBtn;

@property (strong,nonatomic) EDCommentView *commentView;

@property (strong,nonatomic) LoadingIndicatorView *loadingIndicator;

//rendering data
@property (strong,nonatomic) Food *myFood;

//methods

- (id)initWithFrame:(CGRect)frame andVC:(UIViewController *)vc;

//-(void)configPhotoAndTagWithCellNo:(NSInteger)no;

-(void)configCommentTable;

-(void)setVC:(UIViewController *)vc;

-(void)setUpForLargeLayout;

-(void)setUpForSmallLayout;

-(void)prepareForDisplayInCell:(NSInteger)cellNo;

-(void)prepareForDisplay;

-(void)shineDescription;

-(void)cleanUpForReuse;


@end
