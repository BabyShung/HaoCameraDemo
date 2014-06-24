//
//  NavBarSetting.m
//  ScrollingNavbarDemo
//
//  Created by Hao Zheng on 4/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "NavBarSetting.h"

#define EDIBLE_BLUE [UIColor colorWithRed:(46/255.0) green:(181/255.0) blue:(231/255.0) alpha:1]
#define EDIBLE_BLUE_DEEP [UIColor colorWithRed:(0/255.0) green:(149/255.0) blue:(198/255.0) alpha:1]
#define EDIBLE_GRAY [UIColor colorWithRed:(248/255.0) green:(248/255.0) blue:(248/255.0) alpha:1]
@implementation NavBarSetting


-(void)setupNavBar:(UINavigationBar *)tmp{
    // Remember to set the navigation bar to be NOT translucent
	[tmp setTranslucent:NO];
	
	if ([tmp respondsToSelector:@selector(setBarTintColor:)]) {
        [tmp setBarTintColor:EDIBLE_BLUE];
        [[UITabBar appearance] setTintColor:EDIBLE_BLUE_DEEP];
        //[[UITabBar appearance] setBarTintColor:EDIBLE_GRAY];
    }
	
    // For better behavior set statusbar style to opaque on iOS < 7.0
    if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending)) {
        // Silence depracation warnings
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
#pragma clang diagnostic pop
    }
}


/********************
 
 set in appDelegate

 ********************/

-(void)setNavBarTheme{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
	
	if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
        
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
		[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
		NSDictionary *attributes = @{ NSFontAttributeName: [UIFont fontWithName:@"Heiti TC" size:20],
									  NSForegroundColorAttributeName: [UIColor whiteColor]};
		[[UINavigationBar appearance] setTitleTextAttributes:attributes];
        
	}
    

    [[UIBarButtonItem appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:@"Heiti TC" size:14.0], NSFontAttributeName,nil]
                              forState:UIControlStateNormal];
    
}

@end
