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

@interface LoginViewController () <MKTransitionCoordinatorDelegate>


@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.delegate = self;
    
    
    [self.loginBtn primaryStyle];
    
    //animate label
    //[self.animatedLabel animateWithWords:@[@"PolicyApp",@"Like it?"] forDuration:3.0f];
    
    //self.logoView.layer.cornerRadius = 80.0f;

    
    self.userView.layer.cornerRadius = 8;
    self.pwdView.layer.cornerRadius = 8;
    
    [self.userTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.pwdTextField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];


    
}

#pragma mark - MKTransitionCoordinatorDelegate Methods
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow {
    //In this example we don't care where the user is pushing from
    NSLog(@"delegate get called");
    return [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
}

- (IBAction)register:(UIButton *)sender {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Register"] animated:YES];
}

-(BOOL)prefersStatusBarHidden{
    return  YES;
}

- (IBAction)login:(id)sender {
    
    UIWindow *windooo = [[[UIApplication sharedApplication] delegate] window];
    
    
    FrameViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Frame"];
    
    [UIView transitionWithView:windooo
                      duration:1.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ windooo.rootViewController = fvc; }
                    completion:nil];
    
}
@end
