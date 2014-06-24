//
//  MainViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.

#import "MainViewController.h"
#import "largeLayout.h"
#import "TransitionController.h"
#import "debugView.h"
#import "EDCollectionCell.h"

#import "TransitionLayout.h"

#import "SecondViewController.h"

static NSString *CellIdentifier = @"Cell";

@interface MainViewController () <TransitionControllerDelegate>

@property (nonatomic,strong) debugView *debugV;
@property (nonatomic, assign) NSInteger cellCount;

@property (strong,nonatomic) TransitionController *transitionController;

@end

@implementation MainViewController


- (void)viewDidLoad{
    

    //init controls
    [self loadControls];
    
    //self.collectionView.hidden = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //registering dequueue cell
    [self.collectionView registerClass:[EDCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    
    self.cellCount = 10;
    //self.debugV = [[debugView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) andReferenceCV:self];
    //[self.view insertSubview:self.debugV aboveSubview:self.collectionView];
    
    NSLog(@"view did load");
    self.transitionController = [[TransitionController alloc] initWithCollectionView:self.collectionView];
    
    self.transitionController.delegate = self;
    
    self.navigationController.delegate = self.transitionController;
    self.navigationController.navigationBarHidden = YES;

}

-(void)loadControls{
    
    self.camView = [[CameraView alloc] initWithFrame:CGRectMake(0, 0, 320, 568) andOrientation:self.interfaceOrientation andAppliedVC:self];//nil is not using tabbar frame delegate

    [self.view insertSubview:self.camView belowSubview:self.collectionView];

}

- (void) viewDidAppear:(BOOL)animated {

    NSLog(@"yo1?");
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

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.cellCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EDCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    NSLog(@"select IN first");
    
    SecondViewController *viewController = [[SecondViewController alloc] initWithCollectionViewLayout:[[largeLayout alloc] init]];
    
    viewController.useLayoutToLayoutNavigationTransitions = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}


//delegate method, after calling startInteractiveTransition, will call this
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    NSLog(@"begin1 !?");
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}


-(void)addItem
{
    [self.collectionView performBatchUpdates:^{
        self.cellCount = self.cellCount + 1;
        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
        
    } completion:nil];
}


//transitionVC delegate
- (void)interactionBeganAtPoint:(CGPoint)point
{
    NSLog(@"begin3");
    UIViewController *topVC = [self.navigationController topViewController];
    NSLog(@"%@",topVC);
    if([topVC class] == [MainViewController class]){
        SecondViewController *secondVC = [[SecondViewController alloc] initWithCollectionViewLayout:[[largeLayout alloc] init]];
        secondVC.useLayoutToLayoutNavigationTransitions = YES;
        [self.navigationController pushViewController:secondVC animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
