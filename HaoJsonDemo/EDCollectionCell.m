//
//  EDCollectionCell.m
//  Paper
//
//  Created by Hao Zheng on 6/11/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "EDCollectionCell.h"
#import "LoadControls.h"

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
    [self.foodInfoView configureNetworkComponents];
    [self.contentView addSubview:self.foodInfoView];
    
    //[self.foodInfoView configureNetworkComponents];
    //self.foodInfoView.hidden = YES;
    

}

-(void)didTransitionFromLayout:(UICollectionViewLayout *)oldLayout toLayout:(UICollectionViewLayout *)newLayout{
    if (self.frame.size.height == CGRectGetHeight([[UIScreen mainScreen] bounds])){
        NSLog(@"Small ->  Large done");
        NSLog(@"(%f, %f), H:%f , W:%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.height,self.frame.size.width);
        
        [self.foodInfoView setUpForLargeLayout];
        [self.foodInfoView updateUIForFrame:self.bounds];
    }
    else{
        NSLog(@"Large -> Small done");
        NSLog(@"(%f, %f), H:%f , W:%f",self.frame.origin.x,self.frame.origin.y,self.frame.size.height,self.frame.size.width);
        [self.foodInfoView setUpForSmallLayout];
        [self.foodInfoView updateUIForFrame:self.bounds];
    }
}


-(void)setVCForFoodInfoView:(UIViewController *)vc{
    [self.foodInfoView setVC:vc];
}

-(void)layoutSubviews{
    //NSLog(@"Cell layout subviews");
    
    //[self.foodInfoView setFrame:self.bounds];
}


@end
