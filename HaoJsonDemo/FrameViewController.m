//
//  FrameViewController.h
//  PageViewDemo
//
//  Created by Hao Zheng on 5/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FrameViewController.h"
#import "EParentViewController.h"
#import "CameraViewController.h"

#import "DebugViewController.h"

#import "EP_thirdViewController.h"
#import "EP_forthViewController.h"



//tabBar properties
#define TARBAR_HEIGHT 50
#define UPPOINT CGPointMake(160.0f, 543.0f)
#define BOTTOMPOINT CGPointMake(160.0f, 593.0f)

@interface FrameViewController () <EParentVCDelegate>

// four tabbar view controllers
@property (nonatomic,strong) CameraViewController *VC1;
@property (nonatomic,strong) DebugViewController *VC2;
@property (nonatomic,strong) EP_thirdViewController *VC3;
@property (nonatomic,strong) EP_forthViewController *VC4;

//array to store VCs
@property (strong, nonatomic) NSMutableArray *menu;

//current presenting VC index (for later use)
@property ( nonatomic) NSUInteger currentPresentingIndex;

@end

@implementation FrameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //declare all the viewControllers
    self.VC1 = [self.storyboard instantiateViewControllerWithIdentifier:@"camera"];
    self.VC2 = [self.storyboard instantiateViewControllerWithIdentifier:@"debug"];
    self.VC3 = [self.storyboard instantiateViewControllerWithIdentifier:@"vc3"];
    self.VC4 = [self.storyboard instantiateViewControllerWithIdentifier:@"vc4"];
    self.menu = [NSMutableArray arrayWithObjects:self.VC1, self.VC2,self.VC3,self.VC4, nil];
    
    //1. Delegate: set up "passing page index" delegate
    for(int i = 0;i<[self.menu count];i++){
        EParentViewController *tmp = self.menu[i];
        tmp.pageIndex = i;
        tmp.delegate = self;
    }
    
    //2. Delegate: set up VC2(debug) camera delegate as VC1(camera)
    //self.VC1.camView.camDelegate = self.VC2;
    
    //3. Delegate: set up VC3 as the delegate of debugVC
    self.VC2.debugDelegate = self.VC3;
    
    
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

    //bring tabbarView to front
    [self.view bringSubviewToFront:self.tabbarView];
    
    
}


/***********************************************************************
 
 EParentVC delegate methods, coming from other tabbar view controllers
 
 **********************************************************************/

//for debugging
-(void)setCamDelegate:(CameraViewController *)camVC{
    camVC.camView.camDelegate = self.VC2;
}


//check whether need to show or hide tabbar
-(void)checkTabbarStatus:(NSUInteger)index{
    if(index == 0){
        [self hideTabbarView];
    }else{
        [self showTabbarView];
    }
}

-(void)moveToTab:(NSUInteger)index{
    
    NSLog(@"moveToTab:  %d",index);
    [self checkTabbarStatus:index];
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

//tab button click
- (IBAction)clickBtn:(UIButton *)sender {
    [self moveToTab:sender.tag];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((EParentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return self.menu[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((EParentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.menu count]) {
        return nil;
    }
    return self.menu[index];
}


//- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
//{
//    return [self.pageTitles count];
//}

//- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
//{
//    return 0;
//}



//remove nsnotification observer
-(void)dealloc{
    NSLog(@"dealloc...");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"toggleTabbar" object:nil];
}


@end
