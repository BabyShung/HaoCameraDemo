//
//  SecondViewController.m
//  HaoPaper
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "SecondViewController.h"
#import "TransitionLayout.h"
#import "EDCollectionCell.h"

@interface SecondViewController ()

@end

@implementation SecondViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //NSLog(@"c number: %d",[self.collectionView numberOfItemsInSection:0]);
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"second view will appear");
    for(EDCollectionCell *cell in self.collectionView.visibleCells){
        [cell setVCForFoodInfoView:self];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.camView){
        [self.camView pauseCamera];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"view did disappear");
    if(self.camView){
        [self.camView resumeCamera];
    }
}

//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    NSLog(@"begin1 !?");
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    
    return transitionLayout;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"you got it!");
}

@end
