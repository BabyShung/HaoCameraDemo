//
//  SecondViewController.m
//  EdibleHaoLoginRegister
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIButton+Bootstrap.h"

@interface RegisterViewController ()



@end

@implementation RegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.reflectedBG.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    
    [self.signupBtn successStyle];
}

- (IBAction)backToLogin:(UIButton *)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

@end
