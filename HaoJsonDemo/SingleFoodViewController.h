//
//  SingleFoodViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/3/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Food.h"
#import "FoodInfoView.h"

@interface SingleFoodViewController : UIViewController

@property (strong,nonatomic) Food* currentFood;

@property (strong,nonatomic) FoodInfoView *foodInfoView;

@end
