//
//  MRoundedButtonAppearanceManager.m
//  testRunLoop
//
//  Created by Hao Zheng on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "MRoundedButtonAppearanceManager.h"


#pragma mark - MRoundedButtonAppearanceManager
NSString *const kMRoundedButtonCornerRadius                 = @"cornerRadius";
NSString *const kMRoundedButtonBorderWidth                  = @"borderWidth";
NSString *const kMRoundedButtonBorderColor                  = @"borderColor";
NSString *const kMRoundedButtonBorderAnimateToColor         = @"borderAnimateToColor";
NSString *const kMRoundedButtonContentColor                 = @"contentColor";
NSString *const kMRoundedButtonContentAnimateToColor        = @"contentAnimateToColor";
NSString *const kMRoundedButtonForegroundColor              = @"foregroundColor";
NSString *const kMRoundedButtonForegroundAnimateToColor     = @"foregroundAnimateToColor";
NSString *const kMRoundedButtonRestoreSelectedState         = @"restoreSelectedState";

@interface MRoundedButtonAppearanceManager ()
@property (nonatomic, strong)   NSMutableDictionary *appearanceProxys;
@end

@implementation MRoundedButtonAppearanceManager

+ (instancetype)sharedManager
{
    static MRoundedButtonAppearanceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MRoundedButtonAppearanceManager alloc] init];
    });
    
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.appearanceProxys = @{}.mutableCopy;
    }
    
    return self;
}

+ (void)registerAppearanceProxy:(NSDictionary *)proxy forIdentifier:(NSString *)identifier
{
    if (!proxy || ![identifier length])
    {
        return;
    }
    
    MRoundedButtonAppearanceManager *manager = [MRoundedButtonAppearanceManager sharedManager];
    [manager.appearanceProxys setObject:proxy forKey:identifier];
}

+ (void)unregisterAppearanceProxyIdentier:(NSString *)identifier
{
    if (![identifier length])
    {
        return;
    }
    
    MRoundedButtonAppearanceManager *manager = [MRoundedButtonAppearanceManager sharedManager];
    [manager.appearanceProxys removeObjectForKey:identifier];
}

+ (NSDictionary *)appearanceForIdentifier:(NSString *)identifier
{
    return [[MRoundedButtonAppearanceManager sharedManager].appearanceProxys objectForKey:identifier];
}

@end
