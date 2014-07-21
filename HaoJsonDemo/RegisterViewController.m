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
#import "NSUserDefaultControls.h"
#import "LocalizationSystem.h"

#define SignupBTNMoving 60

@interface RegisterViewController () <UITextFieldDelegate>
{
    CGFloat signupBtnY;
}

@property (nonatomic,strong) LoadingAnimation *loadingImage;

@property (weak, nonatomic) IBOutlet UIImageView *signupImageView;

@property (weak, nonatomic) IBOutlet UIButton *backToLoginBtn;
@end

@implementation RegisterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initUI];
    
    //[self checkAndStartLoadingAnimation];
    
    [self loadControls];
}

-(void)initUI{
    self.emailTextField.placeholder = AMLocalizedString(@"Email", nil);
    self.userTextField.placeholder = AMLocalizedString(@"Username", nil);
    self.pwdTextField.placeholder = AMLocalizedString(@"Password", nil);
    [self.signupBtn setTitle:AMLocalizedString(@"SignUp", nil) forState:UIControlStateNormal];
    [self.backToLoginBtn setTitle:AMLocalizedString(@"BackToLogin", nil) forState:UIControlStateNormal];
    
    self.signupImageView.image = iPhone5?[UIImage imageNamed:@"register_ip5_final.png"]:[UIImage imageNamed:@"register_ip4_final.png"];
}

-(void)loadControls{
    [self.emailTextField setValue:[ED_Color mediumGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.userTextField setValue:[ED_Color mediumGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[ED_Color mediumGrayColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.userView.layer.cornerRadius = 5;
    self.pwdView.layer.cornerRadius = 5;
    self.emailView.layer.cornerRadius = 5;
    self.userView.layer.borderColor = [ED_Color lightGrayColor].CGColor;
    self.userView.layer.borderWidth = 1.0f;
    self.pwdView.layer.borderColor = [ED_Color lightGrayColor].CGColor;
    self.pwdView.layer.borderWidth = 1.0f;
    self.emailView.layer.borderColor = [ED_Color lightGrayColor].CGColor;
    self.emailView.layer.borderWidth = 1.0f;
    
    self.pwdTextField.secureTextEntry = YES;
    
    self.emailTextField.delegate = self;
    self.userTextField.delegate = self;
    self.pwdTextField.delegate = self;
    
    [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MySingleTap:)];
    [self.view addGestureRecognizer:singleTap];
    
    signupBtnY = self.signupBtn.center.y;
    
    [self.signupBtn blueCheeseStyle_register];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.emailTextField becomeFirstResponder];
}

- (IBAction)backToLogin:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
        self.backToLoginBtn.enabled = NO;
        [self.view endEditing:YES];
        
        [self checkAndStartLoadingAnimation];
        
        //user register
        [User registerWithEmail:self.emailTextField.text andName:self.userTextField.text andPwd:self.pwdTextField.text andCompletion:^(NSError *err, BOOL success){
            
            if(success){//user info already set
                
                [Flurry logEvent:@"Register_Succeed"];
                
                //save into NSUserDefault
                [NSUserDefaultControls saveUserDictionaryIntoNSUserDefault_dict:[User toDictionary] andKey:@"CurrentUser"];
                
                //transition
                [GeneralControl transitionToVC:self withToVCStoryboardId:@"Frame"];
            }else{
                
                //email already register
                self.signupBtn.enabled = YES;
                self.backToLoginBtn.enabled = YES;
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
                self.signupBtn.center = CGPointMake(160, self.signupBtn.center.y-SignupBTNMoving);
                
            } completion:nil];
        }
    }
}

- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    [self goDownAnimation];
}

-(void)goDownAnimation{
    if(!iPhone5){
        if(self.signupBtn.center.y == signupBtnY - SignupBTNMoving){
            [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.signupBtn.center = CGPointMake(160, self.signupBtn.center.y+SignupBTNMoving);
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
        self.loadingImage.center = CGPointMake(CGRectGetMidX(screenBounds), iPhone5? screenBounds.size.height*0.38:screenBounds.size.height*0.83);
        [self.view addSubview:self.loadingImage];
    }
    [self.loadingImage startAnimating];
}

@end
