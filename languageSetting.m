//
//  languageSetting.m
//  languageTest
//
//  Created by Hao Zheng on 7/14/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "languageSetting.h"
#import "GeneralControl.h"

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
    
    NSString *appLang = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSettingLanguage"];
    if (![lang isEqualToString:appLang]){
    
        [self saveLanguageIntoUserDefault:lang];
        [self setLanguage:lang];
        
    }
}


//save the language into NSUserDefault
-(void)saveLanguageIntoUserDefault:(NSString *)lang{
            //put info into nsuserdefault
        [[NSUserDefaults standardUserDefaults] setObject:lang forKey:@"appSettingLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        NSLog(@"*********saved with %@",lang);
}

//set run-time language
-(void)setLanguage:(NSString *)language{
    LocalizationSetLanguage(language);
}

//get mobile phone current language
-(NSString *)getDeviceLanguage{
    NSLog(@"********* Mobile current language **** %@",LocalizationGetLanguage);
    return LocalizationGetLanguage;
}

-(TargetLang)getAppLanguage{
    NSString *appLang = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSettingLanguage"];
    
    if([appLang isEqualToString:@"en"])
        return English;
    else if([appLang isEqualToString:@"zh-Hans"])
        return Chinese;
    else
        return English;
    
}

-(BOOL)setAppLanguage:(TargetLang)targetLanguage{
    if(targetLanguage==Chinese){
        return [self setAndSaveLanguageAndUpdateUI:@"zh-Hans"];
    }else if(targetLanguage==English){
        return [self setAndSaveLanguageAndUpdateUI:@"en"];
    }
    return false;
}

-(BOOL)setAndSaveLanguageAndUpdateUI:(NSString *)lang{
    NSString *appLang = [[NSUserDefaults standardUserDefaults] stringForKey:@"appSettingLanguage"];
    if (![lang isEqualToString:appLang]){
        
        [self saveLanguageIntoUserDefault:lang];
        [self setLanguage:lang];
        [GeneralControl updatingUI];
        return true;
    }
    return false;
}
@end
