//
//  EParentViewController.h
//  PageViewDemo
//
//  Created by Hao Zheng on 5/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EParentViewController;

/**************
 
 Protocol
 
 ************/

@protocol EParentVCDelegate

@required
- (void) checkTabbarStatus:(NSUInteger) index;

- (void) moveToTab:(NSUInteger) index;

@end


@interface EParentViewController : UIViewController

@property (retain, nonatomic) id <EParentVCDelegate> delegate;

@property (nonatomic) NSUInteger pageIndex;

@end
