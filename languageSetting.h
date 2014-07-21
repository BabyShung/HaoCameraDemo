//
//  languageSetting.h
//  languageTest
//
//  Created by Hao Zheng on 7/14/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizationSystem.h"
#import "ShareData.h"

@interface languageSetting : NSObject

-(void)checkAndSetLanguage;

-(void)setAndSaveLanguage:(NSString *)lang;

-(NSString *)getDeviceLanguage;

-(TargetLang)getAppLanguage;

-(BOOL)setAppLanguage:(TargetLang)targetLanguage;

@end
