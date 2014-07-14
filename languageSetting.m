//
//  languageSetting.m
//  languageTest
//
//  Created by Hao Zheng on 7/14/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "languageSetting.h"

@implementation languageSetting

//used in appDelegate
-(void)checkAndSetLanguage{
    NSString *lang = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSettingLanguage"];
    if (lang){
        LocalizationSetLanguage(lang);
    }else{
        //first time, just save current language to nsuserDefault
        //put info into nsuserdefault
        [[NSUserDefaults standardUserDefaults] setObject:LocalizationGetLanguage forKey:@"appSettingLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        LocalizationSetLanguage(LocalizationGetLanguage);
    }
}

-(void)setAndSaveLanguage:(NSString *)lang{
    [self saveLanguageIntoUserDefault:lang];
    [self setLanguage:lang];
}


//save the language into NSUserDefault
-(void)saveLanguageIntoUserDefault:(NSString *)lang{
    
    NSString *appLang = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSettingLanguage"];
    if (![lang isEqualToString:appLang]){
        
        //put info into nsuserdefault
        [[NSUserDefaults standardUserDefaults] setObject:lang forKey:@"appSettingLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"*********saved with %@",lang);
        
        //also update all the other UI
    }
}

//set run-time language
-(void)setLanguage:(NSString *)language{
    LocalizationSetLanguage(language);
}

//get mobile phone current language
-(NSString *)getAppLanguage{
    return LocalizationGetLanguage;
}




@end
