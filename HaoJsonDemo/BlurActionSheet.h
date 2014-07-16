//
//  BlurActionSheet.h
//  BlueCheese
//
//  Created by Hao Zheng on 6/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlurActionSheet : UIView <UIAppearanceContainer>

- (instancetype)initWithDelegate_cancelButtonTitle:(NSString *)cancelButtonTitle;

- (NSInteger)addButtonWithTitle:(NSString *)title;    // returns index of button. 0 based.
- (NSInteger)addButtonWithTitle:(NSString *)title actionBlock:(void (^)())actionBlock;

@property(nonatomic) CGFloat blurRadius UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor *blurTintColor UI_APPEARANCE_SELECTOR;
@property(nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, strong) UIColor *highlightedButtonColor UI_APPEARANCE_SELECTOR;

@property(nonatomic, readonly) NSInteger cancelButtonIndex;


- (void)show;

@end


