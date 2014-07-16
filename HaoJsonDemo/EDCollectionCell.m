//
//  EDCollectionCell.m
//  Paper
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "EDCollectionCell.h"
#import "LoadControls.h"
#import "largeLayout.h"
#import "smallLayout.h"

@interface EDCollectionCell()

@property (strong,nonatomic,readwrite) NSString *foodTitle;
@end

@implementation EDCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup{
    self.foodInfoView = [[FoodInfoView alloc] initWithFrame:self.bounds];
    [self.foodInfoView setUpForSmallLayout];
    [self.contentView addSubview:self.foodInfoView];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 8.0f;
}

/**********MEI************/
/*                       */
/*   Utility Functions   */
/*                       */
/**********MEI************/

-(void) configFIVForCell:(NSInteger)cellno withFood:(Food *) food{

    self.foodInfoView.myFood = food;
    [self.foodInfoView prepareForDisplayInCell:cellno];
}

-(void)setVCForFoodInfoView:(UIViewController *)vc
{
    [self.foodInfoView setVC:vc];
}

-(void)setUpForLargeLayout
{
    [self.foodInfoView setUpForLargeLayout];
}

-(void)setUpForSmallLayout
{
    [self.foodInfoView setUpForSmallLayout];
}

/**********MEI************/
/*                       */
/*  Delegate Functions   */
/*                       */
/**********MEI************/


-(void)willTransitionFromLayout:(UICollectionViewLayout *)oldLayout
                       toLayout:(UICollectionViewLayout *)newLayout
{
    if ([newLayout class] == [smallLayout class]){
        
        [self.foodInfoView.scrollview setContentOffset:CGPointZero animated:NO];
        [self.foodInfoView setUpForSmallLayout];
    }
    else{
        [self.foodInfoView setUpForLargeLayout];
    }
    
}

-(void)layoutSubviews
{
    
    [self.foodInfoView setFrame:self.bounds];
    
    if (CGRectGetHeight(self.contentView.frame)< CGRectGetHeight([[UIScreen mainScreen] bounds])) {
        self.foodInfoView.commentBtn.alpha = .0f;
        self.foodInfoView.scrollview.scrollEnabled = NO;
        self.foodInfoView.loadingBtn.hidden = YES;
    }
    else{
        [self.foodInfoView shineDescription];
        self.foodInfoView.scrollview.scrollEnabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.foodInfoView.commentBtn.alpha = 1;
        }];
        if (self.foodInfoView.myFood.isFoodInfoCompleted) {
            self.foodInfoView.loadingBtn.hidden = YES;
        }
        else{
            self.foodInfoView.loadingBtn.hidden = NO;
        }
    }
    
}
-(void)prepareForReuse{
    NSLog(@"******************** preparing for reuse ************************");
    [self.foodInfoView cleanUpForReuse];
}

@end
