//
//  AboutUsViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/10/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AboutUsViewController.h"
#import "LoadControls.h"
#import "LocalizationSystem.h"

@interface AboutUsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *contactUsLabel;
@end

@implementation AboutUsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.backgroundImageView.image = [UIImage imageNamed:iPhone5?@"cards_next_no_ip5.png":@"cards_next_no_ip4.png"];
    
    self.contactUsLabel.text = AMLocalizedString(@"CONTACT_US_ABOUT_US", nil);
    
    UIButton *btn = [LoadControls createRoundedBackButton];
    [btn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    self.textView.text = AMLocalizedString(@"ABOUT_US", nil);
}

- (void) previousPagePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
