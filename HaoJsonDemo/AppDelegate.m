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


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    

    /*          MUST BE CALLED AT FIRST        */
    /*Init Sharedata SINGLETON (INIT ONLY ONCE)*/
    
    [ShareData shareDataSetUp];

    //init global search history for main VC
    [SearchDictionary initSharedInstance];
    
//    Food *foodx = [[Food alloc] initWithTitle:@"Tofu" andTranslations:@"豆腐"];
//    Food *foodxx = [[Food alloc] initWithTitle:@"Cola" andTranslations:@"可乐"];
//    [SearchDictionary addSearchHistory:foodx];
//    [SearchDictionary addSearchHistory:foodx];
//    [SearchDictionary addSearchHistory:foodxx];
//    
//    NSLog(@"xxxx %@",foodx);
//    
//   NSLog(@"xxxx2 %@",[[SearchDictionary sharedInstance].dict objectForKey:@"Bacon"]);
//
//    NSLog(@"xx %d",[SearchDictionary sharedInstance].dict.count);
//    [SearchDictionary removeAllSearchHistory];
//    
//    NSLog(@"xx %d",[SearchDictionary sharedInstance].dict.count);
//    
//    
//    SQLConnector *sqlc = [[SQLConnector alloc]init];
//    [sqlc sqliteDBFilePath];
//    

    
    /*Read User default to set target lang*/
    
    // Override point for customization after application launch.
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched before
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        NSLog(@"First time launch");
        
/*                                                                         */
/*                  This will stuck user in opening the app                */
/* A better solution is showing a view that says "installing dictionay"    */
/*                                                                         */
/*    Initial Local DB Set Up, Must Be Done Before First Time Searching    */
/*                    Default Dictionary = Chinese                         */
/*                                                                         */
        //Prepare database
//        DBOperation *operation = [[DBOperation alloc] init];
//        [operation createLangTable:Chinese];
//        [operation createKeywordTable];
//        [operation createSearchHistoryTable];
//        SQLConnector *connector = [SQLConnector sharedInstance];
//        ShareData *sharedata = [ShareData shareData];
//        [connector createEditableCopyOf:[sharedata keywordFileName]];
//        [connector createEditableCopyOf:[sharedata langFileName:Chinese]];
//        [connector createEditableCopyOf:[sharedata filterWordsFileName]];
    }
    
//    Food *food = [[Food alloc] initWithTitle:@"Blue cheese" andTranslations:@"蓝芝士"];
//    Food *food2 = [[Food alloc] initWithTitle:@"Bacon" andTranslations:@"培根"];
//    Food *food3 = [[Food alloc] initWithTitle:@"Onion" andTranslations:@"洋葱"];
//    Food *food4 = [[Food alloc] initWithTitle:@"Apple" andTranslations:@"苹果"];
//    Food *food5 = [[Food alloc] initWithTitle:@"Garlic" andTranslations:@"蒜"];
//    Food *food6 = [[Food alloc] initWithTitle:@"Apple" andTranslations:@"苹果"];
//    Food *food7 = [[Food alloc] initWithTitle:@"Toufu" andTranslations:@"豆腐"];
//    Food *food8 = [[Food alloc] initWithTitle:@"Banana" andTranslations:@"香蕉"];
//    Food *food9 = [[Food alloc] initWithTitle:@"Biscuit" andTranslations:@"饼干"];
//    DBOperation *dbo = [[DBOperation alloc] init];
//    [dbo upsertSearchHistory:food];[dbo upsertSearchHistory:food2];
//    [dbo upsertSearchHistory:food3];[dbo upsertSearchHistory:food4];
//    [dbo upsertSearchHistory:food5];[dbo upsertSearchHistory:food6];
//    [dbo upsertSearchHistory:food7];[dbo upsertSearchHistory:food8];
//    [dbo upsertSearchHistory:food9];
    
    //[dbo fetchSearchHistoryByOrder_withLimitNumber:2];
    
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"will become inactive..");
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"******************* enter Background *******************");
    
    [self.cameraView pauseCamera];
    NSLog(@"CameraIsOn??   %d" , [self.cameraView CameraIsOn]);
    
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if([[self.nvc topViewController] class] == [MainViewController class]){
        [self.cameraView resumeCamera];
        NSLog(@"top vc is main VC");
    }
    
    NSLog(@"******************* enter foreground!  *******************");
     NSLog(@"CameraIsOn??   %d" , [self.cameraView CameraIsOn]);
    
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"did become active..");
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"will terminate..");

    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //store all the query into searchHistory
    [SearchDictionary saveSearchHistoryToLocalDB];
    
    
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
