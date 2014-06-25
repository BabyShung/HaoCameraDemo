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
    
    
    
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.userView.layer.cornerRadius = 5;
    self.pwdView.layer.cornerRadius = 5;
    self.emailView.layer.cornerRadius = 5;
    
    
    [self.signupBtn successStyle];
}

- (IBAction)backToLogin:(UIButton *)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

@end
