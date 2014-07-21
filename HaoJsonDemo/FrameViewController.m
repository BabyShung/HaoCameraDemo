//
//  FrameViewController.h
//  PageViewDemo
//
//  Created by Hao Zheng on 5/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "FrameViewController.h"

#import "CardsViewController.h"

#import "MainViewController.h"

#import "AppDelegate.h"

#import "SettingsViewController.h"

#import "SecondViewController.h"

@interface FrameViewController () <MainVCDelegate,SettingDelegate>

// App view controllers
@property (nonatomic,strong) UINavigationController *VC1;
@property (nonatomic,strong) UINavigationController *VC2;

@property (nonatomic,strong) MainViewController *MVC;
@property (nonatomic,strong) CardsViewController *CVC;

//array to store VCs
@property (strong, nonatomic) NSArray *menu;
@property (strong, nonatomic) NSDictionary *dict;

@end

@implementation FrameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadAllViewControllers];
 
    [self setupPageViewController];

    //save reference in appDelegate for disabling pageviewcontroller
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDlg.fvc = self;
}

-(void)loadAllViewControllers{
    //declare all the viewControllers
    
    UINavigationController *mainNVC = [self.storyboard instantiateViewControllerWithIdentifier:@"mainNVC"];
    self.MVC = (MainViewController * )mainNVC.topViewController;
    //set delegate for DEBUG and slide
    self.MVC.Maindelegate = self;
    
    
    UINavigationController *settingNVC = [self.storyboard instantiateViewControllerWithIdentifier:@"settingNVC"];
    self.CVC = (CardsViewController *)settingNVC.topViewController;
    self.CVC.settingDelegate = self;
    
    self.VC1 = mainNVC;
    self.VC2 = settingNVC;

    self.menu = [NSArray arrayWithObjects:self.VC1, self.VC2, nil];
    
    //a dictionary that knows which index giving a class name of VC
    self.dict = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSNumber numberWithInt:0], mainNVC.restorationIdentifier,
                 [NSNumber numberWithInt:1], settingNVC.restorationIdentifier,
                 nil];
}

-(void)setupPageViewController{
    // Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageVC"];
    self.pageViewController.dataSource = self;
    
    //actually init (called viewDidLoad for all VCs and show self.VC1 to be the first
    for(int i = (int)([self.menu count] - 1); i>=0;i--){
        [self.pageViewController setViewControllers:@[self.menu[i]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, CGRectGetWidth([[UIScreen mainScreen] bounds]), CGRectGetHeight([[UIScreen mainScreen] bounds]));
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    
    self.pageViewController.view.backgroundColor = [UIColor blackColor];
    
}

-(void)slideToCertainPage:(NSInteger)index{
    [self.pageViewController setViewControllers:@[self.menu[index]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

/***********************************************************************
 
 EParentVC delegate methods, coming from other tabbar view controllers
 
 **********************************************************************/
-(void)slideToPreviousPage{
    [self.pageViewController setViewControllers:@[self.menu[0]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
}

-(void)slideToNextPage{
    [self.pageViewController setViewControllers:@[self.menu[1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

//for debug
-(void)slideToDebugPage{
    [self.pageViewController setViewControllers:@[self.menu[2]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void) setCamDelegateFromMain:(MainViewController *)camVC{
    camVC.camView.camDelegate = (id<EdibleCameraDelegate>) camVC;
}

-(NSUInteger)getVCIndex:(UIViewController *) vc{
    NSUInteger index = [[self.dict objectForKey:vc.restorationIdentifier] integerValue];
    return index;
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

-(void)updateAllViewControllers{
    [self.MVC.camView updateUILanguage];
    [self.CVC updateUILanguage];
    [(SettingsViewController *)self.VC2.topViewController updateUILanguage];
}
@end
