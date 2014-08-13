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
#import "GeneralControl.h"
#import "UIView+Toast.h"

const CGFloat kkCommentCellHeight = 50.0f;

@interface SecondViewController () <EDCommentViewDelegate>

@end

@implementation SecondViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //disable pageview
    [GeneralControl setPageViewControllerScrollEnabled:NO];
    
    [self loadControls];
}

-(void)viewDidDisappear:(BOOL)animated{
    //enable pageview
    [GeneralControl setPageViewControllerScrollEnabled:YES];
}

-(void)loadControls{
    //the left bottom button
    _backBtn = [LoadControls createRoundedButton_Image:@"ED_back_2.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andLeftBottomElseRightBottom:YES];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.alpha = 0;
    [self.view insertSubview:_backBtn aboveSubview:self.collectionView];
    
    //the right bottom button
    //add comment button above scrollview
    _commentBtn = [LoadControls createRoundedButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andLeftBottomElseRightBottom:NO];
    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _commentBtn.alpha = 0;
    [self.view insertSubview:_commentBtn aboveSubview:self.collectionView];
    
}

/***********************************/
/*                                 */
/*    Collection View Delegate     */
/*                                 */
/***********************************/

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    //get the cell based on the content offset
    EDCollectionCell *cell = [self getCurrentCell];
    
    //wherever scroll to another cell, check and save food into dict
    [SearchDictionary addSearchHistory:cell.foodInfoView.myFood];

}

-(EDCollectionCell *)getCurrentCell{
    NSIndexPath *centerCellIndex = [self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset];
    EDCollectionCell *cell = (EDCollectionCell *)[self.collectionView cellForItemAtIndexPath:centerCellIndex];
    return cell;
}

//Press back BTN
- (void) backBtnPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//Press comment BTN
- (void) commentBtnPressed:(id)sender {
    
    EDCommentView *commentView = [[EDCommentView alloc]initWithFrame:self.view.frame];
    commentView.delegate = self;
    
    //get the cell based on the content offset
    EDCollectionCell *currentCell = [self getCurrentCell];
    
    
    Comment* lastcomment = [[User sharedInstance].lastComments objectForKey:[NSString stringWithFormat:@"%d",(int)currentCell.foodInfoView.myFood.fid]];
    
    if (!lastcomment) {//will request this food comment by the current
        
        [self.view makeToastActivity];
        [User fetchMyCommentOnFood:currentCell.foodInfoView.myFood.fid andCompletion:^(NSError *err, BOOL success) {
            [self.view hideToastActivity];
            [commentView setWithComment:[[User sharedInstance].lastComments objectForKey:[NSString stringWithFormat:@"%d",(int)currentCell.foodInfoView.myFood.fid]]];
            [commentView setTitleWithFood:currentCell.foodInfoView.myFood.title];
            [commentView open];
        }];
    }
    else{   //lastcomment has been loaded
        //open it immediately
        [commentView setWithComment:lastcomment];
        [commentView setTitleWithFood:currentCell.foodInfoView.myFood.title];
        [commentView open];
    }
    
}

#pragma mark - EDCommentView Delegate

-(void)EDCommentView:(HATransparentView *)edCommentView KeyboardReturnedWithStars:(NSUInteger)stars{
    
    //Comment should be sent!
    EDCommentView *commentView = (EDCommentView *)edCommentView;
    [commentView makeToastActivity];
    
    
    EDCollectionCell *currentCell = [self getCurrentCell];
    
    Comment *newComment = [[Comment alloc]initWithCommentID:0 andFid:currentCell.foodInfoView.myFood.fid andRate:stars andComment:commentView.textView.text];
    
    [[User sharedInstance].lastComments setObject:newComment forKey:[NSString stringWithFormat:@"%d",(int)currentCell.foodInfoView.myFood.fid]];
    
    NSLog(@"+++++++++++++++ FIV +++++WILL SEND COMMENT+++++++++++++++++++");
    [User createComment:newComment andCompletion:^(NSError *err, BOOL success, CGFloat newRate) {
        if (success)
        {
            NSLog(@"+++++++++++++++ FIV +++++SEND COMMENT SUCCEED+++++++++++++++++++");
            [commentView hideToastActivity];
            [commentView close];
            
            //Update rate labels;
            if (newRate>0.f) {
                currentCell.foodInfoView.starNumberLabel.text = [NSString stringWithFormat:@"%.1f",newRate];
            }
            
            [currentCell.foodInfoView makeToast:AMLocalizedString(@"SUCCESS_COMMENT", nil) duration:0.8 position:@"bottom"];
            
            //Remove old comment data
            [currentCell.foodInfoView.myFood.comments removeAllObjects];
            [currentCell.foodInfoView.commentsTableView reloadData];
            
            //update related UI
            currentCell.foodInfoView.commentsTableView.frame = CGRectMake(currentCell.foodInfoView.commentsTableView.frame.origin.x, currentCell.foodInfoView.commentsTableView.frame.origin.y,currentCell.foodInfoView.commentsTableView.frame.size.width, kkCommentCellHeight);
            [currentCell.foodInfoView.scrollview setContentOffset:CGPointZero animated:NO];
            currentCell.foodInfoView.scrollview.contentSize = CGSizeMake(currentCell.foodInfoView.scrollview.contentSize.width,MAX( CGRectGetMaxY(currentCell.foodInfoView.commentsTableView.frame),currentCell.foodInfoView.scrollview.frame.size.height)+10);
            
            //refresh comments
            //[self refreshComments];
        }
        else{
            [commentView hideToastActivity];
            if (!err) {
                [commentView makeToast:AMLocalizedString(@"FAIL_COMMENT", nil) duration:0.8 position:@"center"];
            }
            else{
                [commentView makeToast:AMLocalizedString(@"FAIL_COMMENT_EMOJI", nil) duration:0.8 position:@"center"];
            }
            
        }
    }];
}


-(void)setupButtonAndAnimate{
    //workaround
    [UIView animateWithDuration:.5 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backBtn.alpha = 1;
        [self.view bringSubviewToFront:_backBtn];
        
        _commentBtn.alpha = 1;
        [self.view bringSubviewToFront:_commentBtn];
    } completion:^(BOOL finished){
        [self.view bringSubviewToFront:_backBtn];
        [self.view bringSubviewToFront:_commentBtn];
    }];
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
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout{
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

-(void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    EDCollectionCell *edCell = (EDCollectionCell *)cell;
    edCell.foodInfoView.scrollview.contentOffset = CGPointZero;
//    edCell.foodInfoView.commentBtn.alpha = .0f;
//    edCell.foodInfoView.commentBtn.hidden = YES;
}

@end
