//
//  HintView.m
//  HaoIntroductionHint
//
//  Created by Hao Zheng on 7/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "HintView.h"
#import "MLPSpotlight.h"
#import "LoadControls.h"


#define ARROWCENTER_X 255
#define ARROWCENTER_Y 225

@interface HintView ()

@property (nonatomic, strong) MLPSpotlight *spotLight;

@end

@implementation HintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MySingleTap:)];
        [self addGestureRecognizer:singleTap];
        
        
    }
    return self;
}

-(void)updateSpotLightWithPoint:(CGPoint)point{
    NSArray *existingSpotlights = [MLPSpotlight spotlightsInView:self];
    if(existingSpotlights.count){
        [MLPSpotlight removeSpotlightsInView:self];
    } else {
        [MLPSpotlight addSpotlightInView:self atPoint:point];
    }
    
    UIImage *arrow = [UIImage imageNamed:@"intro_arrow.png"];
    
    UIImageView *imageview = [[UIImageView alloc]initWithImage:arrow];
    imageview.center = CGPointMake(ARROWCENTER_X, ARROWCENTER_Y);
    [self addSubview:imageview];
    
    
    UILabel *label = [LoadControls createLabelWithRect:CGRectZero andTextAlignment:NSTextAlignmentCenter andFont:[UIFont fontWithName:@"Bradley Hand" size:23] andTextColor:[UIColor whiteColor]];
    label.text = @"Draggable at corners";
    [label sizeToFit];
    label.center = CGPointMake(ARROWCENTER_X-100, ARROWCENTER_Y+arrow.size.height);
    
    [self addSubview:label];
}

- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    //[self removeFromSuperview];
    [self.superview removeFromSuperview];
}

@end
