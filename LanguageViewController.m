//
//  LanguageViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/19/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LanguageViewController.h"

@interface LanguageViewController ()

@property (strong,nonatomic) NSArray *languages;

@end

@implementation LanguageViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.languages = [NSArray arrayWithObjects:
                      @"中文",
                      @"English",
                      nil];
    
}



@end
