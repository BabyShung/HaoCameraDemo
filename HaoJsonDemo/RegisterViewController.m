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
   
    [self checkAndStartLoadingAnimation];
    
    [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
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

- (IBAction)backToLogin:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

- (IBAction)signUp:(id)sender {
    [self validateAllInputs];
}

-(void)transitionToFrameVC{
    UIWindow *windooo = [[[UIApplication sharedApplication] delegate] window];
    FrameViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Frame"];
    [UIView transitionWithView:windooo
                      duration:0.8
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        self.view.alpha = 0;
                    }
                    completion:^(BOOL success){
                        windooo.rootViewController = fvc;
                    }];
}

-(void)validateAllInputs{
    //trim
    NSString *trimmedEmail = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    FormValidator *validate=[[FormValidator alloc] init];
    [validate Email:trimmedEmail andUsername:self.userTextField.text andPwd:self.pwdTextField.text];
    
    if([validate isValid]){    //success
        
        [self.view endEditing:YES];
        
        [self checkAndStartLoadingAnimation];
 
        //user register
        [User registerWithEmail:self.emailTextField.text andName:self.userTextField.text andPwd:self.pwdTextField.text andCompletion:^(NSError *err, BOOL success){
            
            if(success){//user info already set
                //transition
                [self transitionToFrameVC];
            }else if(!err){
                
                [self.loadingImage stopAnimating];
                [self showErrorMsg:@"Email or password not correct."];
            }
        }];
        
    }else{  //failure
        NSLog(@"Error Messages From Clinet Side: %@",[validate errorMsg]);
        NSString *errorString = [[validate errorMsg] componentsJoinedByString: @"\n"];
        [self showErrorMsg:errorString];
    }
}

-(void)showErrorMsg:(NSString *)msg{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops.." message:msg delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
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
    
    if(textField.center.y != signupBtnY){
        if(!iPhone5){
            [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                signupBtnY -= 60;
                self.signupBtn.center = CGPointMake(160, signupBtnY);
                
            } completion:nil];
        }
    }
}

- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    [self goDownAnimation];
}

-(void)goDownAnimation{
    if(!iPhone5){
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            signupBtnY += 60;
            self.signupBtn.center = CGPointMake(160, signupBtnY);
        } completion:nil];
    }
    [self.view endEditing:YES];
}

-(void)checkAndStartLoadingAnimation{
    //start animation
    if(!self.loadingImage){
        self.loadingImage = [[LoadingAnimation alloc] initWithStyle:RTSpinKitViewStyleWave color:[UIColor colorWithRed:69/255.0 green:164/255.0 blue:84/255.0 alpha:1]];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.loadingImage.center = CGPointMake(CGRectGetMidX(screenBounds), iPhone5? screenBounds.size.height*0.4:screenBounds.size.height*0.5);
        [self.view addSubview:self.loadingImage];
    }
    [self.loadingImage startAnimating];
}

@end
