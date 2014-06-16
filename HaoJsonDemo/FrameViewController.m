//
//  FrameViewController.h
//  PageViewDemo
//
//  Created by Hao Zheng on 5/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FrameViewController.h"
#import "EParentViewController.h"


#import "DebugViewController.h"

#import "EP_thirdViewController.h"
#import "EP_forthViewController.h"

#import "MainViewController.h"
#import "TransitionController.h"
#import "CVSmallLayout.h"

//tabBar properties
#define TARBAR_HEIGHT 50
#define UPPOINT CGPointMake(160.0f, 543.0f)
#define BOTTOMPOINT CGPointMake(160.0f, 593.0f)

@interface FrameViewController () <EParentVCDelegate,MainVCDelegate,UINavigationControllerDelegate, TransitionControllerDelegate>

// four tabbar view controllers
@property (nonatomic,strong) UINavigationController *VC1;
@property (nonatomic,strong) DebugViewController *VC2;
@property (nonatomic,strong) EP_thirdViewController *VC3;
@property (nonatomic,strong) EP_forthViewController *VC4;

//array to store VCs
@property (strong, nonatomic) NSMutableArray *menu;
@property (strong, nonatomic) NSDictionary *dict;

//current presenting VC index (for later use)
@property ( nonatomic) NSUInteger currentPresentingIndex;

@property (nonatomic) UINavigationController *navigationController;
@property (nonatomic) TransitionController *transitionController;

@end

@implementation FrameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self setupMainViewController];
    
    //declare all the viewControllers
    //self.VC1 = [self.storyboard instantiateViewControllerWithIdentifier:@"camera"];
    self.VC2 = [self.storyboard instantiateViewControllerWithIdentifier:@"debug"];
    self.VC3 = [self.storyboard instantiateViewControllerWithIdentifier:@"vc3"];
    self.VC4 = [self.storyboard instantiateViewControllerWithIdentifier:@"vc4"];
    self.menu = [NSMutableArray arrayWithObjects:self.VC1, self.VC2,self.VC3,self.VC4, nil];
    
    //a dictionary that knows which index giving a class name of VC
    self.dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], [self.navigationController class],[NSNumber numberWithInt:0], [self.VC1 class], [NSNumber numberWithInt:1], [self.VC2 class], [NSNumber numberWithInt:2], [self.VC3 class], [NSNumber numberWithInt:3], [self.VC4 class], nil];
 
    
    //1. Delegate: set up "passing page index" delegate
    for(int i = 1;i<[self.menu count];i++){
        EParentViewController *tmp = self.menu[i];
        tmp.delegate = self;
    }
    
    //2. Delegate: set up VC3 as the delegate of debugVC
    self.VC2.debugDelegate = self.VC3;
    
    [self setupPageViewController];

    //bring tabbarView to front
    [self.view bringSubviewToFront:self.tabbarView];
    
}

-(void)setupMainViewController{
    //specify layout for cVC and init
    CVSmallLayout *smallLayout = [[CVSmallLayout alloc] init];
    
    MainViewController *mvc = [[MainViewController alloc] initWithCollectionViewLayout:smallLayout];

    
    
    //push cVC into nVC
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mvc];
    self.navigationController.delegate = self;
    self.navigationController.navigationBarHidden = YES;
    
    //also init transition class
    self.transitionController = [[TransitionController alloc] initWithCollectionView:mvc.collectionView];
    self.transitionController.tranDelegate = self;
    
    self.VC1 = self.navigationController;
    mvc.Maindelegate = self;
    
    
    NSLog(@"mvc.view---------------------");
    NSLog(@"X: %f", mvc.view.bounds.origin.x);
    NSLog(@"Y: %f", mvc.view.bounds.origin.y);
    NSLog(@"width: %f", mvc.view.bounds.size.width);
    NSLog(@"height: %f", mvc.view.bounds.size.height);
}

-(void)setupPageViewController{
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageVC"];
    self.pageViewController.dataSource = self;
    
    //actually init (called viewDidLoad for all VCs and show self.VC1 to be the first
    for(int i = [self.menu count] - 1; i>=0;i--){
        [self.pageViewController setViewControllers:@[self.menu[i]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

/***********************************************************************
 
 EParentVC delegate methods, coming from other tabbar view controllers
 
 **********************************************************************/

- (void) setCamDelegateFromMain:(MainViewController *)camVC{
    camVC.camView.camDelegate = self.VC2;
}

//check whether need to show or hide tabbar
-(void)checkTabbarStatus:(UIViewController *) vc{
    NSUInteger index = [self getVCIndex:vc];
    if(index == 0){
        [self hideTabbarView];
    }else{
        [self showTabbarView];
    }
}

- (void) moveToTabFromMainVC:(NSUInteger) index{
    [self moveToTab:index];
}

-(void)moveToTab:(NSUInteger) index{
    NSLog(@"moveToTab:  %lu",(unsigned long)index);
    if(index == 0){
        [self hideTabbarView];
    }else{
        [self showTabbarView];
    }
    [self.pageViewController setViewControllers:@[self.menu[index]] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:nil];
}

-(void)showTabbarView{
    if(CGPointEqualToPoint(self.tabbarView.center, BOTTOMPOINT)){
        [UIView animateWithDuration:0.6 animations:^{   //go up
            self.tabbarView.center = UPPOINT;
            self.tabbarView.alpha = 1;
        }];
    }
}

-(void)hideTabbarView{
    if(CGPointEqualToPoint(self.tabbarView.center, UPPOINT)){
        [UIView animateWithDuration:0.5 animations:^{   //go down
            self.tabbarView.center = BOTTOMPOINT;
            self.tabbarView.alpha = 0.8;
        }];
    }
}

-(NSUInteger)getVCIndex:(UIViewController *) vc{
    return[[self.dict objectForKey:[vc class]] integerValue];
}

//tab button click
- (IBAction)clickBtn:(UIButton *)sender {
    [self moveToTab:sender.tag];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self getVCIndex:viewController];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return self.menu[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self getVCIndex:viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.menu count]) {
        return nil;
    }
    return self.menu[index];
}

//***** Delegate method from TVC
- (void)interactionBeganAtPoint:(CGPoint)point
{
    // Very basic communication between the transition controller and the top view controller
    // It would be easy to add more control, support pop, push or no-op
    MainViewController *presentingVC = (MainViewController *)[self.navigationController topViewController];
    
    MainViewController *presentedVC = (MainViewController *)[presentingVC nextViewControllerAtPoint:point];
    
    if (presentedVC!=nil){
        [self.navigationController pushViewController:presentedVC animated:YES];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSLog(@"transition Delegate ******");
}

//***** Delegate method from NVC
- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    if (animationController==self.transitionController) {
        return self.transitionController;
    }
    return nil;
}


- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (![fromVC isKindOfClass:[UICollectionViewController class]] || ![toVC isKindOfClass:[UICollectionViewController class]])
    {
        return nil;
    }
    if (!self.transitionController.hasActiveInteraction)
    {
        return nil;
    }
    
    self.transitionController.navigationOperation = operation;
    return self.transitionController;
}

@end
