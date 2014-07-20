//
//  introContainer.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/19/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "introContainer.h"
#import "HintView.h"
#import "EAIntroView.h"
#import "SMPageControl.h"

@interface introContainer () <EAIntroDelegate>



@end

@implementation introContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showIntroWithCrossDissolve {
    
    NSString *sampleDescription1 = @"aa";
    NSString *sampleDescription2 = @"bb";
    NSString *sampleDescription3 = @"cc";
    NSString *sampleDescription4 = @"dd";
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello world";
    page1.desc = sampleDescription1;
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"This is page 2";
    page2.desc = sampleDescription2;
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title2"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"This is page 3";
    page3.desc = sampleDescription3;
    page3.bgImage = [UIImage imageNamed:@"bg3"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"This is page 4";
    page4.desc = sampleDescription4;
    page4.bgImage = [UIImage imageNamed:@"bg4"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.bounds andPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    
    [intro showInView:self animateDuration:0.3];
}

//introduction view delegate
- (void)introDidFinish:(EAIntroView *)introView {
    
    if(self.shouldShowHint){
        HintView *hv = [[HintView alloc] initWithFrame:self.frame];
        [self addSubview:hv];
        [hv updateSpotLightWithPoint:CGPointMake(300, 189)];
    }else{
        //must be clicking tutorial btn
        [self removeFromSuperview];
    }
    
    
    
}

@end
