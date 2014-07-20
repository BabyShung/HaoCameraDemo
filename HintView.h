//
//  HintView.h
//  HaoIntroductionHint
//
//  Created by Hao Zheng on 7/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HintView : UIView

-(void)updateSpotLightWithPoint:(CGPoint)point;

-(void)updateSpotLightWithPoint_alsoAddsDragStaff:(CGPoint)point;

@end
