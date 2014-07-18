//
//  HintView.m
//  HaoIntroductionHint
//
//  Created by Hao Zheng on 7/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "HintView.h"
#import "MLPSpotlight.h"

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
}

- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    [self removeFromSuperview];
}

@end
