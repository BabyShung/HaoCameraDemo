//
//  FirstViewController.h
//  MyPolicyCard
//
//  Created by Hao Zheng on 6/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingDelegate
@required

//slide VC in PageViewController
- (void) slideToPreviousPage;

@end

@interface CardsViewController : UIViewController

@property (retain, nonatomic) id <SettingDelegate> settingDelegate;

-(void)updateUILanguage;

@end
