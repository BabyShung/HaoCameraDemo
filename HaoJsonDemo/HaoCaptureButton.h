//
//  HaoCaptureButton.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRoundedButtonAppearanceManager.h"
#import "CameraView.h"

typedef NS_ENUM(NSInteger, MRoundedButtonStyle) {
    MRoundedButtonDefault,
    MRoundedButtonSubtitle,
    MRoundedButtonCentralImage,
    MRoundedButtonImageWithSubtitle
};

extern CGFloat const MRoundedButtonMaxValue;

@interface HaoCaptureButton : UIControl

@property (readonly, nonatomic) MRoundedButtonStyle         mr_buttonStyle;

@property (nonatomic, assign)   CGFloat                     cornerRadius               UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign)   CGFloat                     borderWidth                UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)   UIColor                     *borderColor               UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)   UIColor                     *contentColor              UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)   UIColor                     *foregroundColor           UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)   UIColor                     *borderAnimateToColor      UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)   UIColor                     *contentAnimateToColor     UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong)   UIColor                     *foregroundAnimateToColor  UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign)   BOOL                        restoreSelectedState       UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak)     UILabel                     *textLabel;
@property (nonatomic, weak)     UILabel                     *detailTextLabel;
@property (nonatomic, weak)     UIImageView                 *imageView;
@property (nonatomic, assign)   UIEdgeInsets                contentEdgeInsets;


- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(MRoundedButtonStyle)style
         appearanceIdentifier:(NSString *)identifier andCameraView:(UIView *)camView;

@end





