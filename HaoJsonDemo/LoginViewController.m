//
//  ViewController.m
//  EdibleHaoLoginRegister
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MKTransitionCoordinator.h"
#import "UIButton+Bootstrap.h"
#import "FrameViewController.h"
#import "User.h"
#import "FormValidator.h"
#import "LoadingAnimation.h"
#import "ED_Color.h"
#import "UIResponder+KeyboardCache.h"

@interface LoginViewController () <MKTransitionCoordinatorDelegate,UITextFieldDelegate>


@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;

@property (nonatomic,strong) LoadingAnimation *loadingImage;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //cache keyboard
    [UIResponder cacheKeyboard];
    
    //[self checkAndStartLoadingAnimation];

    //[[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"CurrentUser"];
    //[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentUser"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"]) {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"];
        //from dictionary to User instance
        [User fromDictionaryToUser:dict];
        
        [self transitionToFrameVC_duration:0];
        
        NSLog(@"******************  Second Login: %@",[User sharedInstance]);
        
        
    }else{
        self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
        self.menuInteractor.delegate = self;
        
        [self.loginBtn primaryStyle];
        
        self.userView.layer.cornerRadius = 5;
        self.pwdView.layer.cornerRadius = 5;
        
        [self.emailTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
        
        [self.emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
        self.pwdTextField.secureTextEntry = YES;
        
        self.emailTextField.delegate = self;
        self.pwdTextField.delegate = self;
        
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MySingleTap:)];
        [self.view addGestureRecognizer:singleTap];
    }
}


#pragma mark - MKTransitionCoordinatorDelegate Methods
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow {

    //[self MySingleTap:nil];
    [self.view endEditing:YES];
    return [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
}

- (IBAction)register:(UIButton *)sender {
        [self.view endEditing:YES];
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Register"] animated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

- (IBAction)login:(id)sender {
    [self validateAllInputs];
}

-(void)transitionToFrameVC_duration:(CGFloat) duration{
    UIWindow *windooo = [[[UIApplication sharedApplication] delegate] window];
    FrameViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Frame"];
    [UIView transitionWithView:windooo
                      duration:duration
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
    [validate Email:trimmedEmail andUsername:nil andPwd:self.pwdTextField.text];
    
    if([validate isValid]){    //success
        
        [self.view endEditing:YES];
        [self checkAndStartLoadingAnimation];
        
        //user login
        [User loginWithEmail:trimmedEmail andPwd:self.pwdTextField.text andCompletion:^(NSError *err, BOOL success){
            if(success){//user info already set
                
                //User info already set
                NSDictionary *dict = [User toDictionary];
                //put info into nsuserdefault
                [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"CurrentUser"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSLog(@"%@",[User sharedInstance]);
                
                
                //transition
                [self transitionToFrameVC_duration:0.5];
            }else if(!err){
                
                [self.loadingImage stopAnimating];
                [self showErrorMsg:@"Email or password not correct."];
            }
        }];
        
    }else{  //failure
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
        [self.pwdTextField becomeFirstResponder];
    }else if(theTextField == self.pwdTextField){
        [self validateAllInputs];
    }
    return NO;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [self goUpAnimation];
}

- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    [self goDownAnimation];
}

-(void)goUpAnimation{
    if(self.bgScrollView.bounds.origin.y != 175){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.bgScrollView setContentOffset:CGPointMake(0,175) animated:YES];
        });
    }
}

-(void)goDownAnimation{
    if(self.bgScrollView.bounds.origin.y != 0){
        [self.bgScrollView setContentOffset:CGPointMake(0,0) animated:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
        });
    }
}

-(void)checkAndStartLoadingAnimation{
    //start animation
    if(!self.loadingImage){
        self.loadingImage = [[LoadingAnimation alloc] initWithStyle:RTSpinKitViewStyleWave color:[ED_Color edibleBlueColor_DeepDark]];
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        self.loadingImage.center = CGPointMake(CGRectGetMidX(screenBounds), iPhone5? screenBounds.size.height*0.7:screenBounds.size.height*0.82);
        [self.view addSubview:self.loadingImage];
    }
    [self.loadingImage startAnimating];
}


@end
