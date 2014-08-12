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
#import "LoadControls.h"

#define TitlePositionY_ip5 524
#define TitlePositionY_ip4 445
#define DescPositionY_ip5 104
#define DescPositionY_ip4 91
#define TitleFontSize 20
#define DescFontFontSize 15

@interface introContainer () <EAIntroDelegate>

@property (nonatomic,strong) UILabel *scaleLabel;
@property (nonatomic,strong) UILabel *draggableLabel;
@property (nonatomic,strong) UILabel *draggableLabel2;

@end

@implementation introContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupLocalizedLabels];
        
    }
    return self;
}

-(void)setupLocalizedLabels{
    CGRect scaleRect = iPhone5?CGRectMake(22, 200, 50, 30):CGRectMake(35, 169, 50, 30);
    CGRect drag1Rect = iPhone5?CGRectMake(228, 209, 80, 30):CGRectMake(210, 178, 80, 30);
    CGRect drag2Rect = iPhone5?CGRectMake(203, 140, 80, 30):CGRectMake(190, 119, 80, 30);
    
    CGFloat dragFontSize = iPhone5?14:12;
    
    _scaleLabel = [LoadControls createLabelWithRect:scaleRect andTextAlignment:NSTextAlignmentCenter andFont:[UIFont boldSystemFontOfSize:14] andTextColor:[UIColor whiteColor]];
    _scaleLabel.text = AMLocalizedString(@"TUTORIAL_SCALE_TEXT", nil);
    
    _draggableLabel = [LoadControls createLabelWithRect:drag1Rect andTextAlignment:NSTextAlignmentCenter andFont:[UIFont boldSystemFontOfSize:dragFontSize] andTextColor:[UIColor whiteColor]];
    _draggableLabel.text = AMLocalizedString(@"TUTORIAL_DRAG_TEXT", nil);
    
    _draggableLabel2 = [LoadControls createLabelWithRect:drag2Rect andTextAlignment:NSTextAlignmentCenter andFont:[UIFont boldSystemFontOfSize:dragFontSize] andTextColor:[UIColor whiteColor]];
    _draggableLabel2.text = AMLocalizedString(@"TUTORIAL_DRAG_TEXT", nil);
    
    _scaleLabel.hidden = YES;
    _draggableLabel.hidden = YES;
    _draggableLabel2.hidden = YES;
    
    [self addSubview:_scaleLabel];
    [self addSubview:_draggableLabel];
    [self addSubview:_draggableLabel2];
}

-(void)hideLabelsOrNot:(BOOL)show{
    
    for (UILabel * label in @[_scaleLabel, _draggableLabel, _draggableLabel2]) {
        label.hidden = show;
        if(show){
            [self bringSubviewToFront:label];
        }
    }
}

-(void)showScaleAndDraggableLabel{
    for (UILabel * label in @[_scaleLabel, _draggableLabel]) {
        label.hidden = NO;
        [self bringSubviewToFront:label];
    }
}

-(void)showDraggableLabel{
    _draggableLabel2.hidden = NO;
    [self bringSubviewToFront:_draggableLabel2];
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
    
//    UIView *viewForPage2 = [[UIView alloc] initWithFrame:self.bounds];
//    UILabel *labelForPage2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, 100, 30)];
//    labelForPage2.text = @"Some custom view";
//    labelForPage2.font = [UIFont systemFontOfSize:22];
//    labelForPage2.textColor = [UIColor whiteColor];
//    labelForPage2.backgroundColor = [UIColor clearColor];
//    [viewForPage2 addSubview:labelForPage2];
//
//    EAIntroPage *page2 = [EAIntroPage pageWithCustomView:viewForPage2];
    
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
    //intro.useMotionEffects = NO;
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

-(void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{
    [self hideLabelsOrNot:YES];
}

-(void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{
    if(!introView)
        [self hideLabelsOrNot:YES];
    
    if(pageIndex == 0){
    }
    else if(pageIndex == 1){
        [self showScaleAndDraggableLabel];
        
        
    }else if(pageIndex == 2){
        [self showDraggableLabel];
        
    }else if(pageIndex == 3){
    }
    
}

@end
