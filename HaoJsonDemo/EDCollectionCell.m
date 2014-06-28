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

@end

@implementation EDCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"CELL INIT");
        [self setup];
    }
    return self;
}

-(void)setup{
    self.foodInfoView = [[FoodInfoView alloc] initWithFrame:self.bounds];
    [self.foodInfoView setUpForSmallLayout];
    //[self.foodInfoView configureNetworkComponentswithCellNo:self.];
    [self.contentView addSubview:self.foodInfoView];
    
    

}

/**********MEI************/
/*                       */
/*   Utility Functions   */
/*                       */
/**********MEI************/

-(void) setCellWithFood:(Food *)food{
    [self.foodInfoView setWithFood:food];

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
        NSLog(@" Will do large -> small");

        [self.foodInfoView setUpForSmallLayout];
    }
    else{
        NSLog(@" Will do small -> large");

        [self.foodInfoView setUpForLargeLayout];
    }
    
}

-(void)layoutSubviews
{
    
    [self.foodInfoView setFrame:self.bounds];
    
    if (CGRectGetHeight(self.contentView.frame)< CGRectGetHeight([[UIScreen mainScreen] bounds])) {
        self.foodInfoView.scrollview.scrollEnabled = NO;
    }
    else{
        [self.foodInfoView shineDescription];
        self.foodInfoView.scrollview.scrollEnabled = YES;
    }
    NSLog(@"Cell layout subviews");
    
}


@end
