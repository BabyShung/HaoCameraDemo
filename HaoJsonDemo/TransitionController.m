//
//  HATransitionController.m
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "TransitionController.h"
#import "TransitionLayout.h"
#import "largeLayout.h"
#import "EDCollectionCell.h"

@interface TransitionController () 

@property (nonatomic) TransitionLayout* transitionLayout;

@property (nonatomic) id <UIViewControllerContextTransitioning> context;

@property (nonatomic) CGFloat initialPinchDistance;

@property (nonatomic) CGPoint initialPinchPoint;

@property (nonatomic) CGFloat initialScale;

@property (nonatomic) CGPoint lastPoint;

//@property (nonatomic) EDCollectionCell *currentCell;
@end

@implementation TransitionController

- (instancetype)initWithCollectionView:(UICollectionView *)collectionView
{
    self = [super init];
    if (self != nil)
    {
        //pan
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerGesture:)];
        panGestureRecognizer.delegate = self;
        panGestureRecognizer.minimumNumberOfTouches = 1;
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        [collectionView addGestureRecognizer:panGestureRecognizer];
        
        self.collectionView = collectionView;
        
        
        
    }
    return self;
}


- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    NSLog(@"begin5");
    if (animationController==self) {
        return self;
    }
    return nil;
}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if (![fromVC isKindOfClass:[UICollectionViewController class]] || ![toVC isKindOfClass:[UICollectionViewController class]])
    {
        return nil;
    }
    if (!self.hasActiveInteraction)
    {
        return nil;
    }
    NSLog(@"begin4");
    self.navigationOperation = operation;
    return self;
}


#pragma mark - UIGestureRecognizerDelegate

//multi gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

//-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    NSLog(@"000000000000000000000000");
//    return YES;
//}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{

}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    // transition animation time between grid and stack layout
    return 1.0;
}

/*****************************************************************************
 Required method for view controller transitions
 
 called when the system needs to set up the interactive portions of a view controller transition and start the animations
 
 ****************************************************************************/
- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    NSLog(@"x");
    self.context = transitionContext;
    UIView *containerView = [transitionContext containerView];
    
    UICollectionViewController *fromCollectionVC =
    (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UICollectionViewController *toCollectionVC =
    (UICollectionViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    

    [containerView addSubview:[toCollectionVC view]];

    self.transitionLayout = (TransitionLayout *)[fromCollectionVC.collectionView startInteractiveTransitionToCollectionViewLayout:toCollectionVC.collectionViewLayout completion:^(BOOL didFinish, BOOL didComplete) {
        [self.context completeTransition:didComplete];
        self.transitionLayout = nil;
        self.context = nil;
        self.hasActiveInteraction = NO;
        
        
//        SecondViewController *svc;
//        
//        if([toCollectionVC class] == [SecondViewController class]){
//            
//            svc = (SecondViewController *)toCollectionVC;
//
//            [svc.view bringSubviewToFront:svc.backBtn];
//        }
        
        
    }];
}

- (void)updateWithProgress:(CGFloat)progress andOffset:(UIOffset)offset
{
    if (self.context != nil &&  // we must have a valid context for updates
        ((progress != self.transitionLayout.transitionProgress) || !UIOffsetEqualToOffset(offset, self.transitionLayout.offset)))
    {
        [self.transitionLayout setOffset:offset];
        [self.transitionLayout setTransitionProgress:progress];
        [self.transitionLayout invalidateLayout];
        [self.context updateInteractiveTransition:progress];
    }
}

/*****************************************************************************
 
 Called by our pinch gesture recognizer when the gesture has finished or cancelled, which
 in turn is responsible for finishing or cancelling the transition.
 
 *****************************************************************************/
- (void)endInteractionWithSuccess:(BOOL)success
{
    if (self.context == nil)
    {
        self.hasActiveInteraction = NO;
    }
    else if(self.transitionLayout.transitionProgress <0.1){
        //NSLog(@"+++ TC +++ : I cancel interactive transition");

        //[self enableCollectionView];
        [self.collectionView cancelInteractiveTransition];
        [self.context cancelInteractiveTransition];
    }
    else if (success){
         //NSLog(@"+++ TC +++ : I will finish interactive transition");
        [self.collectionView finishInteractiveTransition];
        [self.context finishInteractiveTransition];
    }
}


/*****************************
 
 Pan gesture recognizer
 interctive transition triggered in this order:
 oneFingerGesture.interactionBeganAtPoint()->AppDelegate.interactionBeganAtPoint()
 ->PaperCellVC.nextViewControllerAtPoint(); 
 Animated Push->TransitionController.interactiveTransitionStart()
 
 *****************************/
- (void)oneFingerGesture:(UIPanGestureRecognizer *)sender
{
    CGFloat screenH = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    CGPoint point = [sender locationInView:sender.view];
    CGPoint velocity = [sender velocityInView:sender.view];
    CGPoint translate = [sender translationInView:sender.view];
    //CGFloat smallLayoutH = iPhone5 ?1.1:1.3;//iPhone5? 185:155;
    
    switch (sender.state) {
        default:
            [self endInteractionWithSuccess:NO];
            break;
        case UIGestureRecognizerStateEnded:
            [self endInteractionWithSuccess:YES];
            break;
        case UIGestureRecognizerStateBegan:
            if (sender.numberOfTouches == 1) {
                 //NSLog(@"+++ TC +++ : A 1 finger gesture began");
                self.initialPinchPoint = point;
                 EDCollectionCell *cell = (EDCollectionCell *)[self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:point]];
                //fabsf(velocity.y/velocity.x)>2
                if (!self.hasActiveInteraction && velocity.y>0 && fabsf(velocity.y/velocity.x)>2 && cell.foodInfoView.scrollview.contentOffset.y<=0){
                    
                    //NSLog(@"+++ TC +++ : I will start interactive transition");
                    self.hasActiveInteraction = YES; // the transition is in active motion
                    //[self.collectionView selectItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:point] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                    
                    [self.delegate interactionBeganAtPoint:point];
                }
            }
            break;
        case UIGestureRecognizerStateChanged:
            if (self.hasActiveInteraction){
                CGFloat distance = sqrt(translate.x*translate.x + translate.y*translate.y);
                //CGFloat offsetX = translate.x;
                CGFloat offsetX = 0;
                CGFloat offsetY = translate.y-distance;


                CGFloat ratio =(point.y - self.initialPinchPoint.y)/(screenH-self.initialPinchPoint.y);
                
                UIOffset offsetToUse = UIOffsetMake(offsetX, offsetY);
                CGFloat progress = MAX(MIN(ratio, 1.0), 0.0);
                
                [self updateWithProgress:progress andOffset:offsetToUse];
                
            }//user scroll horizonally /*****   THINK TWICE   ******/
            else if(velocity.y && fabsf(velocity.y/velocity.x)<=2 && self.collectionView.contentOffset.x>0 && (self.collectionView.contentOffset.x + self.collectionView.frame.size.width != self.collectionView.contentSize.width)){
                
                EDCollectionCell *cell = (EDCollectionCell *)[self.collectionView cellForItemAtIndexPath:[self.collectionView indexPathForItemAtPoint:self.initialPinchPoint]];
                if (!cell.foodInfoView.photoCollectionView.isTracking) {
                    //NSLog(@"+++++++++ TC ++++++++++++ : USER IS SCROLLING");
                    //NSLog(@")))))))))))))))))))))))))))) %@",cell.foodInfoView.myFood.title);
                   // cell.foodInfoView.commentBtn.alpha = 1-fabsf(translate.x/100);
                }

            
            }
            break;
            
    }
}

@end
