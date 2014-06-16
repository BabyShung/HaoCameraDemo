//
//  MainViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.

#import "MainViewController.h"
#import "CVLargeLayout.h"

@interface MainViewController ()

@end

@implementation MainViewController

//did select
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIViewController *vc = [self nextViewControllerAtPoint:CGPointZero];
    [self.navigationController pushViewController:vc animated:YES];
}

//overwrite??
- (UICollectionViewController *)nextViewControllerAtPoint:(CGPoint)point
{
    // We could have multiple section stacks and find the right one,
    CVLargeLayout *largeLayout = [[CVLargeLayout alloc] init];
    
    DetailViewController *nextCollectionVC = [[DetailViewController alloc] initWithCollectionViewLayout:largeLayout];

    
    nextCollectionVC.useLayoutToLayoutNavigationTransitions = YES;
    
    return nextCollectionVC;
}

- (void)viewDidLoad{
    
    NSLog(@"--------------- Small layout View did load ---------------");
    
    [super viewDidLoad];

    //init controls
    [self loadControls];
    
    self.collectionView.hidden = YES;

}

-(void)loadControls{
//    NSLog(@"self.view---------------------");
//    NSLog(@"X: %f", self.view.bounds.origin.x);
//    NSLog(@"Y: %f", self.view.bounds.origin.y);
//    NSLog(@"width: %f", self.view.bounds.size.width);
//    NSLog(@"height: %f", self.view.bounds.size.height);
    
    self.camView = [[CameraView alloc] initWithFrame:CGRectMake(0, 0, 320, 568) andOrientation:self.interfaceOrientation andAppliedVC:self];//nil is not using tabbar frame delegate

    [self.view insertSubview:self.camView belowSubview:self.collectionView];
//    NSLog(@"self.camView---------------------");
//    NSLog(@"X: %f", self.camView.bounds.origin.x);
//    NSLog(@"Y: %f", self.camView.bounds.origin.y);
//    NSLog(@"width: %f", self.camView.bounds.size.width);
//    NSLog(@"height: %f", self.camView.bounds.size.height);

}

- (void) viewDidAppear:(BOOL)animated {
    
    NSLog(@"width: %f", self.collectionView.bounds.size.width);
    NSLog(@"height: %f", self.collectionView.bounds.size.height);
    
    //Hao: important to change tabbar index
    [self.Maindelegate checkTabbarStatus:self];
    
    
    //set camView delegate to be DEBUG_VC
    [self.Maindelegate setCamDelegateFromMain:self];
    
    
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.camView.StreamView.alpha = 1;
        self.camView.rotationCover.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([(NSObject *)self.camView.camDelegate respondsToSelector:@selector(EdibleCameraDidLoadCameraIntoView:)]) {
                [self.camView.camDelegate EdibleCameraDidLoadCameraIntoView:self];
            }
        }
    }];
    
    
    
    
//    [UICollectionView transitionWithView:self.collectionView
//                                duration:1
//                                 options:UIViewAnimationOptionTransitionCrossDissolve
//                              animations:NULL
//                              completion:NULL];
//    self.collectionView.hidden = YES;
//    NSLog(@"isHidden: %d",self.collectionView.isHidden);
}


@end
