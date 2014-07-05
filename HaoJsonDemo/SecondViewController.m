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

@interface SecondViewController () <HATransparentViewDelegate>

@property (strong,nonatomic) CameraView *camView;

@property (strong, nonatomic) UIButton * backBtn;

@property (strong, nonatomic) UIButton * commentBtn;

@property (strong, nonatomic) HATransparentView *transparentView;

@property (strong, nonatomic) DXStarRatingView *rateView;


@end

@implementation SecondViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.camView = [appDlg getCamView];
    
    
    
}


#pragma mark - RatingDelegate
- (void)didChangeRating:(NSNumber*)newRating
{
    NSLog(@"didChangeRating: %@",newRating);
}

#pragma mark - HATransparentViewDelegate

- (void)HATransparentViewDidClosed
{
    NSLog(@"Did close");
}

- (void) backBtnPressed:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) commentBtnPressed:(id)sender {
    _transparentView = [[HATransparentView alloc] init];
    _transparentView.delegate = self;
    [_transparentView open];
    
    
    // Add a textView
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 120, _transparentView.frame.size.width - 40, 250)];
    textView.text = @"asdasdasdasdasdqweqweaxczxczxcasdwqesdfadsfasdfasdfsafasf";
    //textView.backgroundColor = [UIColor clearColor];
    textView.textColor = [UIColor blackColor];
    textView.editable = YES;
    textView.font = [UIFont systemFontOfSize:20];
    [_transparentView addSubview:textView];
    
    self.rateView = [[DXStarRatingView alloc] initWithFrame:CGRectMake((_transparentView.frame.size.width - 250)/2, 60, 260, 65)];
    [self.rateView setStars:0 target:self callbackAction:@selector(didChangeRating:)];
    [_transparentView addSubview:self.rateView];
}

-(void)setupButtonAndAnimate{
    _backBtn = [LoadControls createCameraButton_Image:@"ED_back_2.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andCenter:CGPointMake(10+20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
    [_backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _backBtn.alpha = 0;
    //_backBtn.hidden = YES;
    [self.view insertSubview:_backBtn aboveSubview:self.collectionView];
    
    _commentBtn = [LoadControls createCameraButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andCenter:CGPointMake(320-10-20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _commentBtn.alpha = 0;
    //_commentBtn.hidden = YES;
    [self.view insertSubview:_commentBtn aboveSubview:self.collectionView];
    
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backBtn.alpha = 1;
        _commentBtn.alpha = 1;
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
    
    
    
    
    //NSLog(@"+++ 2ndVC +++ : I did appear");
    //scroll DE speed fast
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    
    //remove this part, not good code
    if(self.camView){
        [self.camView pauseCamera];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    //NSLog(@"+++ 2ndVC +++ : I did disappear");
    if(self.camView){
        [self.camView resumeCamera];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    //NSLog(@"+++ 2ndVC +++ : I will disappear");
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
    EDCollectionCell *edCell = (EDCollectionCell *)cell;
    edCell.foodInfoView.scrollview.contentOffset = CGPointZero;
}


@end
