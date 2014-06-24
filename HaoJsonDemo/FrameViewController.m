//
//  FrameViewController.h
//  PageViewDemo
//
//  Created by Hao Zheng on 5/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FrameViewController.h"


#import "DebugViewController.h"

#import "EP_thirdViewController.h"

#import "CardsViewController.h"

#import "MainViewController.h"


@interface FrameViewController () <MainVCDelegate>

// four tabbar view controllers
@property (nonatomic,strong) UINavigationController *VC1;
@property (nonatomic,strong) UINavigationController *VC2;
@property (nonatomic,strong) DebugViewController *VC3;
@property (nonatomic,strong) EP_thirdViewController *VC4;

//array to store VCs
@property (strong, nonatomic) NSMutableArray *menu;
@property (strong, nonatomic) NSDictionary *dict;

@end

@implementation FrameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    //declare all the viewControllers
    
    UINavigationController *mainNVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNVC"];
    MainViewController *mvcInDict = (MainViewController * )mainNVC.topViewController;
    //set delegate for DEBUG
    mvcInDict.Maindelegate = self;
    
    
    UINavigationController *settingNVC = [self.storyboard instantiateViewControllerWithIdentifier:@"settingNVC"];
    
    
    self.VC1 = mainNVC;
    self.VC2 = settingNVC;
    self.VC3 = [self.storyboard instantiateViewControllerWithIdentifier:@"debug"];
    self.VC4 = [self.storyboard instantiateViewControllerWithIdentifier:@"debug2"];
    //2. Delegate: set up VC4 as the delegate of debugVC
    self.VC3.debugDelegate = self.VC4;
    
    
    
    self.menu = [NSMutableArray arrayWithObjects:self.VC1, self.VC2,self.VC3,self.VC4, nil];
    
    //a dictionary that knows which index giving a class name of VC
    self.dict = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSNumber numberWithInt:0], mainNVC.restorationIdentifier,
                 [NSNumber numberWithInt:1], settingNVC.restorationIdentifier,
                 [NSNumber numberWithInt:2], self.VC3.restorationIdentifier,
                 [NSNumber numberWithInt:3], self.VC4.restorationIdentifier, nil];
 


    
    [self setupPageViewController];

    
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
    NSLog(@"yo2?");
    camVC.camView.camDelegate = self.VC3;
}

-(NSUInteger)getVCIndex:(UIViewController *) vc{
    return[[self.dict objectForKey:vc.restorationIdentifier] integerValue];
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


@end
