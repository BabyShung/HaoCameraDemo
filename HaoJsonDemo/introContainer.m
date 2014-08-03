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
#import "LocalizationSystem.h"
#import "ED_Color.h"


#define TitlePositionY_ip5 524
#define TitlePositionY_ip4 445
#define DescPositionY_ip5 104
#define DescPositionY_ip4 91
#define TitleFontSize 20
#define DescFontFontSize 15

@interface introContainer () <EAIntroDelegate>
@end

@implementation introContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)showIntroWithCrossDissolve {
    
    NSString *d1 = AMLocalizedString(@"T1_description_DESCRIPTION", nil);
    NSString *d2 = AMLocalizedString(@"T2_description_DESCRIPTION", nil);
    NSString *d3 = AMLocalizedString(@"T3_description_DESCRIPTION", nil);
    NSString *d4 = AMLocalizedString(@"T4_description_DESCRIPTION", nil);
    
    NSString *t1 = AMLocalizedString(@"T1_title_DESCRIPTION", nil);
    NSString *t2 = AMLocalizedString(@"T2_title_DESCRIPTION", nil);
    NSString *t3 = AMLocalizedString(@"T3_title_DESCRIPTION", nil);
    NSString *t4 = AMLocalizedString(@"T4_title_DESCRIPTION", nil);
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = t1;
    page1.titleFont = [UIFont fontWithName:@"STHeitiTC-Medium" size:TitleFontSize];
    page1.titlePositionY = iPhone5?TitlePositionY_ip5:TitlePositionY_ip4;
    page1.desc = d1;
    page1.descPositionY = iPhone5?DescPositionY_ip5:DescPositionY_ip4;
    page1.descColor = [ED_Color darkGrayColor];
    page1.descWidth = [AMLocalizedString(@"T1_description_width", nil) integerValue];
    page1.descFont = [UIFont fontWithName:@"Heiti TC" size:DescFontFontSize];
    page1.bgImage = [UIImage imageNamed:iPhone5?@"tutorial_1_ip5.png":@"tutorial_1_ip4.png"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = t2;
    page2.titleFont = [UIFont fontWithName:@"Heiti TC" size:TitleFontSize];
    page2.titlePositionY = iPhone5?TitlePositionY_ip5:TitlePositionY_ip4;
    page2.desc = d2;
    page2.descPositionY = iPhone5?DescPositionY_ip5:DescPositionY_ip4;
    page2.descColor = [ED_Color darkGrayColor];
    page2.descWidth = [AMLocalizedString(@"T2_description_width", nil) integerValue];
    page2.descFont = [UIFont fontWithName:@"Heiti TC" size:DescFontFontSize];
    page2.bgImage = [UIImage imageNamed:iPhone5?@"tutorial_2_ip5.png":@"tutorial_2_ip4.png"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = t3;
    page3.titleFont = [UIFont fontWithName:@"Heiti TC" size:TitleFontSize];
    page3.titlePositionY = iPhone5?TitlePositionY_ip5:TitlePositionY_ip4;
    page3.desc = d3;
    page3.descPositionY = iPhone5?DescPositionY_ip5:DescPositionY_ip4;
    page3.descColor = [ED_Color darkGrayColor];
    page3.descWidth = [AMLocalizedString(@"T3_description_width", nil) integerValue];
    page3.descFont = [UIFont fontWithName:@"Heiti TC" size:DescFontFontSize];
    page3.bgImage = [UIImage imageNamed:iPhone5?@"tutorial_3_ip5.png":@"tutorial_3_ip4.png"];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = t4;
    page4.titleFont = [UIFont fontWithName:@"Heiti TC" size:TitleFontSize];
    page4.titlePositionY = iPhone5?TitlePositionY_ip5:TitlePositionY_ip4;
    page4.desc = d4;
    page4.descPositionY = iPhone5?DescPositionY_ip5:DescPositionY_ip4;
    page4.descColor = [ED_Color darkGrayColor];
    page4.descWidth = [AMLocalizedString(@"T4_description_width", nil) integerValue];
    page4.descFont = [UIFont fontWithName:@"Heiti TC" size:DescFontFontSize];
    page4.bgImage = [UIImage imageNamed:iPhone5?@"tutorial_4_ip5.png":@"tutorial_4_ip4.png"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.bounds andPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    intro.tapToNext = YES;
    
//    intro.pageControl.hidden = YES;
//    intro.skipButton.hidden = YES;
    
    intro.pageControl.currentPageIndicatorTintColor = [ED_Color darkGrayColor];
    intro.pageControl.pageIndicatorTintColor = [ED_Color lightGrayColor];
    //intro.pageControlY = 60;
    [intro.skipButton setTitleColor:[ED_Color skip_Gray] forState:UIControlStateNormal];
    [intro showInView:self animateDuration:0.3];
}

//introduction view delegate
- (void)introDidFinish:(EAIntroView *)introView {
    
    if(self.shouldShowHint){
        HintView *hv = [[HintView alloc] initWithFrame:self.frame];
        [self addSubview:hv];
        [hv updateSpotLightWithPoint_alsoAddsDragStaff:CGPointMake(300, 189)];
    }else{
        //must be clicking tutorial btn
        [self removeFromSuperview];
    }
}

@end
