//
//  debugView.m
//  Paper
//
//  Created by Hao Zheng on 6/14/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "debugView.h"
#import "MainViewController.h"

@interface debugView ()

@property (strong, nonatomic) UIButton * insertBtn;
@property (strong, nonatomic) UIButton * deleteBtn;
@property (strong, nonatomic) MainViewController * referenceVC;
@end

@implementation debugView

- (id)initWithFrame:(CGRect)frame andReferenceCV:(MainViewController *) vc
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.referenceVC = vc;
        [self setup];
    }
    return self;
}


-(void)setup{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button addTarget:self action:@selector(insertPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"insert" forState:UIControlStateNormal];
    button.frame = CGRectMake(10.0, 50.0, 160.0, 40.0);
    button.backgroundColor = [UIColor grayColor];
    [self addSubview:button];
    
    _insertBtn = button;
    
}

- (void) insertPressed:(id)sender {
    //[self.referenceVC addItem];
}


@end
