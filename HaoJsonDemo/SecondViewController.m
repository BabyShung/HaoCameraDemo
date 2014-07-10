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
#import "AppDelegate.h"
#import "LoadControls.h"
#import "ED_Color.h"
#import "HATransparentView.h"
#import "DXStarRatingView.h"

#import "SearchDictionary.h"
#import "User.h"

@interface SecondViewController () <HATransparentViewDelegate>

@property (strong, nonatomic) UIButton * backBtn;

//@property (strong, nonatomic) UIButton * commentBtn;

@property (strong, nonatomic) HATransparentView *transparentView;

@property (strong, nonatomic) DXStarRatingView *rateView;


@property (strong, nonatomic) UILabel *wordCountLabel;

@property (strong, nonatomic) NSMutableString *wordStr;

@property (nonatomic) NSUInteger currentFid;

@property (nonatomic) NSUInteger currentStars;

@property (strong,nonatomic) Comment *currentComment;

@property (nonatomic) BOOL willSendComment;



@end
const NSInteger MaxCharNum = 20;
@implementation SecondViewController

//-(void)showCommentButton:(NSNotification*)notification{
//    NSLog(@"yoyoyoxxxxx*********************************************** yoyoyoyoyo");
//    
//    //get food id
//    NSUInteger fid = [[notification.userInfo objectForKey:@"fid"] intValue];
//    
//    //get uid
//    User *user = [User sharedInstance];
//    if(user.Uid != 0){
//        //show comment button
//    }
//}


- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCommentButton:) name:@"showCmtButton" object:nil];

}
-(void)dealloc
{
    //[[NSNotificationCenter defaultCenter]removeObserver:self name:@"showCmtButton" object:nil];
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
    //if (!cell.foodInfoView.commentBtn.isHidden) {

        [UIView animateWithDuration:0.5 animations:^{
            cell.foodInfoView.commentBtn.alpha = 1;
        }];
    //}
    
    
    
    //tell the secondVC whether it can show the comment button
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"showCmtButton" object:self userInfo:@{@"food":cell.myFood}];
    
    
    
}


//#pragma mark - RatingDelegate
//- (void)didChangeRating:(NSNumber*)newRating
//{
//    _currentStars = [newRating unsignedIntegerValue];
//    NSLog(@"didChangeRating: %@",newRating);
//}
//
//#pragma mark - HATransparentViewDelegate
//
//- (void)HATransparentViewDidClosed
//{
//    [User sharedInstance].latestComment = _currentComment;
//    NSLog(@"Did close");
//    //clean up and reload all visible cells comment table
//    //
//}

- (void) backBtnPressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//- (void) commentBtnPressed:(id)sender {
//    
//    NSLog(@"+++ 2ND VC +++ : collection view content offset = (%f,%f), screen W = %f",self.collectionView.contentOffset.x,self.collectionView.contentOffset.y,CGRectGetWidth([[UIScreen mainScreen] bounds]));
//    
//    EDCollectionCell *commentCell = (EDCollectionCell *)[self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:self.collectionView.contentOffset]];
//    NSLog(@"+++ 2ND VC +++ : comment on %@",commentCell.foodInfoView.myFood.title);
//    _currentFid = commentCell.foodInfoView.myFood.fid;
//    
//    [User fetchMyCommentOnFood:_currentFid andCompletion:^(NSError *err, BOOL success)
//    {
//        if (success) {
//            _willSendComment = NO;
//            _currentComment =nil;
//            _transparentView = [[HATransparentView alloc] init];
//            _transparentView.delegate = self;
//            [_transparentView open];
//            
//            // Add a textView
//            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 120, _transparentView.frame.size.width - 40, 250)];
//            textView.textColor = [UIColor blackColor];
//            textView.editable = YES;
//            textView.font = [UIFont systemFontOfSize:20];
//            [textView setReturnKeyType:UIReturnKeySend];
//            textView.delegate = self;
//            
//            self.rateView = [[DXStarRatingView alloc] initWithFrame:CGRectMake((_transparentView.frame.size.width - 250)/2, 60, 260, 65)];
//            
//            _wordCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(textView.frame)-100, CGRectGetMaxY(textView.frame)-50, 100, 50)];
//            _wordCountLabel.textColor = [UIColor lightGrayColor];
//            _wordStr = [[NSMutableString alloc]initWithFormat:@"%d",(int)MaxCharNum];
//            _wordCountLabel.text =_wordStr;
//            _wordCountLabel.textAlignment = NSTextAlignmentRight;
//            //textView.backgroundColor = [UIColor clearColor];
//            
//            
//            if ([User sharedInstance].latestComment) {
//                textView.text = [User sharedInstance].latestComment.text;
//                [self.rateView setStars:(int)[User sharedInstance].latestComment.rate target:self callbackAction:@selector(didChangeRating:)];
//            }
//            else{
//                //textView.text = @"Please comment...";
//                [self.rateView setStars:3 target:self callbackAction:@selector(didChangeRating:)];
//            }
//            [_transparentView addSubview:textView];
//            [_transparentView addSubview:self.rateView];
//            [_transparentView addSubview:_wordCountLabel];
//        }
//    }];
//    
//
//}

//- (void) commentBtnPressed:(id)sender {
//    _transparentView = [[HATransparentView alloc] init];
//    _transparentView.delegate = self;
//    [_transparentView open];
//    
//    
//    // Add a textView
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 120, _transparentView.frame.size.width - 40, 250)];
//    textView.text = @"asdasdasdasdasdqweqweaxczxczxcasdwqesdfadsfasdfasdfsafasf";
//    //textView.backgroundColor = [UIColor clearColor];
//    textView.textColor = [UIColor blackColor];
//    textView.editable = YES;
//    textView.font = [UIFont systemFontOfSize:20];
//    [_transparentView addSubview:textView];
//    
//    self.rateView = [[DXStarRatingView alloc] initWithFrame:CGRectMake((_transparentView.frame.size.width - 250)/2, 60, 260, 65)];
//    [self.rateView setStars:0 target:self callbackAction:@selector(didChangeRating:)];
//    [_transparentView addSubview:self.rateView];
//}



-(void)setupButtonAndAnimate{
    _backBtn = [LoadControls createRoundedButton_Image:@"ED_back_2.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andCenter:CGPointMake(10+20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.alpha = 0;
    //_backBtn.hidden = YES;
    [self.view insertSubview:_backBtn aboveSubview:self.collectionView];
    
//    _commentBtn = [LoadControls createCameraButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andCenter:CGPointMake(320-10-20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
//    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    _commentBtn.alpha = 0;
//    
//    if ([User sharedInstance].Uid == 0) {
//        _commentBtn.hidden = YES;
//    }
//    else{
//        _commentBtn.hidden = NO;
//    }
//    
//    [self.view insertSubview:_commentBtn aboveSubview:self.collectionView];

//    _commentBtn = [LoadControls createCameraButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andCenter:CGPointMake(320-10-20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
//    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
//    _commentBtn.alpha = 0;
//    //_commentBtn.hidden = YES;
//    [self.view insertSubview:_commentBtn aboveSubview:self.collectionView];

    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backBtn.alpha = 1;
        //_commentBtn.alpha = 1;
    } completion:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    //NSLog(@"+++ 2ndVC +++ : I will appear");
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

//-(BOOL)prefersStatusBarHidden{
//    return YES;
//}

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
/********************/
/* TextView delegate*/
/********************/
//-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
//    if ([text isEqualToString:@"\n"]) {
//        _willSendComment = YES;
//        [textView resignFirstResponder];
//        return NO;
//    }
//    
//    return YES;
//}

/*-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > MaxCharNum) {
        textView.text = [textView.text substringToIndex:MaxCharNum];
    }
    [_wordStr setString:@""];
    [_wordStr appendFormat:@"%i",(int)(MaxCharNum - textView.text.length)];
    self.wordCountLabel.text =_wordStr;
    
}*/

/*-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSLog(@"+++ 2ND VC +++ : text view end editing");
    if (!_currentComment) {
        NSLog(@"+++ 2ND VC +++ : init a new comment");
        _currentComment = [[Comment alloc]initWithCommentID:0 andFid:_currentFid andRate:_currentStars andComment:textView.text];
    }

    if (_willSendComment) {
        NSLog(@"+++ 2ND VC +++ : will send a comment");
        [User createComment:_currentComment andCompletion:^(NSError *err, BOOL success) {
            if (success) {
                NSLog(@"+++ 2ND VC +++ : comment sent!");
                _willSendComment = NO;
                [_transparentView close];
            }
        }];
    }

    //post comment
    
    
}*/
@end
