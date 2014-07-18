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
#import "LoadControls.h"
#import "ED_Color.h"
#import "SearchDictionary.h"
#import "User.h"
#import "FrameViewController.h"
#import "GeneralControl.h"

@interface SecondViewController ()

@property (strong, nonatomic) UIButton * backBtn;

@property (strong, nonatomic) UILabel *wordCountLabel;

@property (strong, nonatomic) NSMutableString *wordStr;

@property (nonatomic) NSUInteger currentFid;

@property (nonatomic) NSUInteger currentStars;

@property (strong,nonatomic) Comment *currentComment;

@property (nonatomic) BOOL willSendComment;

@end

@implementation SecondViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [GeneralControl setPageViewControllerScrollEnabled:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [GeneralControl setPageViewControllerScrollEnabled:YES];
}




/***********************************/
/*                                 */
/*    Collection View Delegate     */
/*                                 */
/***********************************/


-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

        NSIndexPath *centerCellIndex = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
        EDCollectionCell *cell = (EDCollectionCell *)[self.collectionView cellForItemAtIndexPath:centerCellIndex];
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~++++++++++++++++++ %d",(int)centerCellIndex.row);
        //wherever scroll to another cell, check and save food into dict
        [SearchDictionary addSearchHistory:cell.foodInfoView.myFood];

        [UIView animateWithDuration:0.5 animations:^{
            cell.foodInfoView.commentBtn.alpha = 1;
        }];

}



- (void) backBtnPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}


-(void)setupButtonAndAnimate{
    _backBtn = [LoadControls createRoundedButton_Image:@"ED_back_2.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andLeftBottomElseRightBottom:YES];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.alpha = 0;
    //_backBtn.hidden = YES;
    [self.view insertSubview:_backBtn aboveSubview:self.collectionView];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backBtn.alpha = 1;
        //_commentBtn.alpha = 1;
    } completion:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    for(EDCollectionCell *cell in self.collectionView.visibleCells){
        [cell setVCForFoodInfoView:self];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    
    //set up buttons
    [self setupButtonAndAnimate];
    
    //scroll DE speed fast
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    EDCollectionCell *edCell = (EDCollectionCell *)cell;
    edCell.foodInfoView.scrollview.contentOffset = CGPointZero;
    
    edCell.foodInfoView.commentBtn.alpha = .0f;
    edCell.foodInfoView.commentBtn.hidden = YES;
    //[User sharedInstance].latestComment = nil;
}
@end
