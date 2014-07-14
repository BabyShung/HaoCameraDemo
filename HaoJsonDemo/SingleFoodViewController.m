//
//  SingleFoodViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/3/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "SingleFoodViewController.h"
#import "LoadControls.h"
#import "ED_Color.h"

@interface SingleFoodViewController ()

@property (strong, nonatomic) UIButton *backBtn;

@end

@implementation SingleFoodViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"%@",self.currentFood);
    
    
    //1.add foodInfoView
    
    
    //2.add backBtn
    [self loadControls];
}


-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)loadControls{

    self.foodInfoView = [[FoodInfoView alloc] initWithFrame:self.view.bounds andVC:self];
    self.foodInfoView.myFood = self.currentFood;
    [self.foodInfoView prepareForDisplay];
    [self.view addSubview:self.foodInfoView];
    
    _backBtn = [LoadControls createRoundedButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andCenter:CGPointMake(10+20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20)];
    [_backBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    


}

- (void) previousPagePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
