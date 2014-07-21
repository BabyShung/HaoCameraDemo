//
//  AppDelegate.m
//  HaoJsonDemo
//
//  Created by Hao Zheng on 4/12/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AppDelegate.h"
#import "SQLConnector.h"
#import "ShareData.h"
#import "DBOperation.h"
#import "SearchDictionary.h"
#import "MainViewController.h"
#import "Flurry.h"
#import "languageSetting.h"
#import "NSUserDefaultControls.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"BJKGTKRHXZGZC4VD3RZ9"];
    /*          MUST BE CALLED AT FIRST        */
    /*Init Sharedata SINGLETON (INIT ONLY ONCE)*/
    
    [ShareData shareDataSetUp];

    //init global search history for main VC
    [SearchDictionary initSharedInstance];
    
    languageSetting *ls = [[languageSetting alloc]init];
    [ls checkAndSetLanguage];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application{
    NSLog(@"will become inactive..");
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    NSLog(@"************************* enter Background ***************************");
    [self.cameraView pauseCamera];
    NSLog(@"CameraIsOn??   %d" , [self.cameraView CameraIsOn]);
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    if([[self.nvc topViewController] class] == [MainViewController class]){
        [self.cameraView resumeCamera];
        NSLog(@"top vc is main VC");
    }
    NSLog(@"*************************** enter Foreground!  ***************************");
     NSLog(@"CameraIsOn??   %d" , [self.cameraView CameraIsOn]);
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"did become active..");
}

- (void)applicationWillTerminate:(UIApplication *)application{
    //store all the query into searchHistory
    [SearchDictionary saveSearchHistoryToLocalDB];
    [self closeCamera];
}

-(CameraView *)getCamView{
    return self.cameraView;
}

-(void)closeCamera{
    [self.cameraView closeWithCompletionWithoutDismissing:^(){
        NSLog(@"In app delegate: camera closed");
    }];
}

@end
