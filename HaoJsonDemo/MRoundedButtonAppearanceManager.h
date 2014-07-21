//
//  MRoundedButtonAppearanceManager.h
//  testRunLoop
//
//  Created by Hao Zheng on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString *const kMRoundedButtonCornerRadius;
extern NSString *const kMRoundedButtonBorderWidth;
extern NSString *const kMRoundedButtonBorderColor;
extern NSString *const kMRoundedButtonContentColor;
extern NSString *const kMRoundedButtonForegroundColor;
extern NSString *const kMRoundedButtonBorderAnimateToColor;
extern NSString *const kMRoundedButtonContentAnimateToColor;
extern NSString *const kMRoundedButtonForegroundAnimateToColor;
extern NSString *const kMRoundedButtonRestoreSelectedState;

@interface MRoundedButtonAppearanceManager : NSObject

+ (void)registerAppearanceProxy:(NSDictionary *)proxy forIdentifier:(NSString *)identifier;
+ (void)unregisterAppearanceProxyIdentier:(NSString *)identifier;
+ (NSDictionary *)appearanceForIdentifier:(NSString *)identifier;

@end


