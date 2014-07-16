//
//  SecondViewController.m
//  EdibleHaoLoginRegister
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIButton+Bootstrap.h"
#import "User.h"
#import "FrameViewController.h"
#import "FormValidator.h"
#import "LoadingAnimation.h"
#import "ED_Color.h"
#import "UIAlertView+Blocks.h"
#import "Flurry.h"
#import "GeneralControl.h"

@interface RegisterViewController () <UITextFieldDelegate>
{
    CGFloat signupBtnY;
}

@property (nonatomic,strong) LoadingAnimation *loadingImage;

@end

@implementation RegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self checkAndStartLoadingAnimation];
    
    [self loadControls];
}

-(void)loadControls{
    [self.emailTextField setValue:[ED_Color lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userTextField setValue:[ED_Color lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[ED_Color lightGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.userView.layer.cornerRadius = 5;
    self.pwdView.layer.cornerRadius = 5;
    self.emailView.layer.cornerRadius = 5;
    
    self.pwdTextField.secureTextEntry = YES;
    
    self.emailTextField.delegate = self;
    self.userTextField.delegate = self;
    self.pwdTextField.delegate = self;
    
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MySingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    signupBtnY = self.signupBtn.center.y;
    
    [self.signupBtn successStyle];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.emailTextField becomeFirstResponder];
}

- (IBAction)backToLogin:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

- (IBAction)signUp:(id)sender {
    [self validateAllInputs];
}

-(void)validateAllInputs{
    //trim
    NSString *trimmedEmail = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    FormValidator *validate=[[FormValidator alloc] init];
    [validate Email:trimmedEmail andUsername:self.userTextField.text andPwd:self.pwdTextField.text];
    
    if([validate isValid]){    //success
        
        [Flurry logEvent:@"Read_To_Register"];
        
        self.signupBtn.enabled = NO;
        [self.view endEditing:YES];
        
        [self checkAndStartLoadingAnimation];
        
        //user register
        [User registerWithEmail:self.emailTextField.text andName:self.userTextField.text andPwd:self.pwdTextField.text andCompletion:^(NSError *err, BOOL success){
            
            if(success){//user info already set
                
                [Flurry logEvent:@"Register_Succeed"];
                
                //save into NSUserDefault
                [GeneralControl saveUserDictionaryIntoNSUserDefault_dict:[User toDictionary] andKey:@"CurrentUser"];
                
                //transition
                [GeneralControl transitionToVC:self withToVCStoryboardId:@"Frame"];
            }else{
                
                //email already register
                self.signupBtn.enabled = YES;
                [self.loadingImage stopAnimating];
                [GeneralControl showErrorMsg:[err localizedDescription] withTextField:self.emailTextField];
            }
        }];
        
    }else{  //failure
        NSString *errorString = [[validate errorMsg] componentsJoinedByString: @"\n"];
        [GeneralControl showErrorMsg:errorString withTextField:nil];
    }
}

/********************************************
 
 textfield delegate methods: clicking return
 
 ****************************************/

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if(theTextField == self.emailTextField){
        [self.userTextField becomeFirstResponder];
    }else if(theTextField == self.userTextField){
        [self.pwdTextField becomeFirstResponder];
    }else if(theTextField == self.pwdTextField){
        [self validateAllInputs];
    }
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    
    if(!iPhone5){
        if(self.signupBtn.center.y == signupBtnY){
            [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.signupBtn.center = CGPointMake(160, self.signupBtn.center.y-50);
                
            } completion:nil];
        }
    }
}

- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    [self goDownAnimation];
}

-(void)goDownAnimation{
    if(!iPhone5){
        if(self.signupBtn.center.y == signupBtnY - 50){
            [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.signupBtn.center = CGPointMake(160, self.signupBtn.center.y+50);
            } completion:nil];
        }
    }
    [self.view endEditing:YES];
}

-(void)checkAndStartLoadingAnimation{
    
    //start animation
    if(!self.loadingImage){
        self.loadingImage = [[LoadingAnimation alloc] initWithStyle:RTSpinKitViewStyleWave color:[ED_Color edibleGreenColor]];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.loadingImage.center = CGPointMake(CGRectGetMidX(screenBounds), iPhone5? screenBounds.size.height*0.4:screenBounds.size.height*0.6);
        [self.view addSubview:self.loadingImage];
    }
    [self.loadingImage startAnimating];
}

@end
