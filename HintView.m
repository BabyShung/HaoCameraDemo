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
#import "LocalizationSystem.h"

#define DRAG_ARROWCENTER_X 255
#define DRAG_ARROWCENTER_Y 225
#define SLIDER_ARROWCENTER_X 95
#define SLIDER_ARROWCENTER_Y_ip5 315
#define SLIDER_ARROWCENTER_Y_ip4 255
#define CAPTURE_ARROWCENTER_X 125
#define CAPTURE_ARROWCENTER_Y_ip5 394
#define CAPTURE_ARROWCENTER_Y_ip4 315
@interface HintView ()

@property (nonatomic, strong) MLPSpotlight *spotLight;

@property (nonatomic) NSInteger hintsNumber;
@property (nonatomic,strong) UIImageView *arrowImageView;
@property (nonatomic,strong) UIImageView *photoImageView;
@end

@implementation HintView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hintsNumber = 3;
        
        self.backgroundColor = [UIColor clearColor];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(MySingleTap:)];
        [self addGestureRecognizer:singleTap];
        
    }
    return self;
}

-(void)updateSpotLightWithPoint_alsoAddsDragStaff:(CGPoint)point{
    [self updateSpotLightWithPoint:point];
    [self addHintArrowImage:@"intro_arrow_right_up.png" andArrowCenter:CGPointMake(DRAG_ARROWCENTER_X, DRAG_ARROWCENTER_Y) andAddPhotoName:AMLocalizedString(@"TUTORIAL_D_IMAGENAME", nil) andImageViewCenter:CGPointMake(DRAG_ARROWCENTER_X-100, DRAG_ARROWCENTER_Y+70)];
}

-(void)updateSpotLightWithPoint:(CGPoint)point{
    NSArray *existingSpotlights = [MLPSpotlight spotlightsInView:self];
    if(existingSpotlights.count){
        [MLPSpotlight removeSpotlightsInView:self];
    }
    [MLPSpotlight addSpotlightInView:self atPoint:point];

}

-(void)addHintArrowImage:(NSString*)arrowName andArrowCenter:(CGPoint)arrowCenter andAddPhotoName:(NSString *)photoname andImageViewCenter:(CGPoint)PhotoCenter{
    
    [_arrowImageView removeFromSuperview];
    [_photoImageView removeFromSuperview];
    
    UIImage *arrow = [UIImage imageNamed:arrowName];
    
    _arrowImageView = [[UIImageView alloc]initWithImage:arrow];
    _arrowImageView.center = arrowCenter;
    [self addSubview:_arrowImageView];
    
    UIImage *photo = [UIImage imageNamed:photoname];
    
    _photoImageView = [[UIImageView alloc]initWithImage:photo];
    _photoImageView.center = PhotoCenter;
    [self addSubview:_photoImageView];

}


- (void)MySingleTap:(UITapGestureRecognizer *)sender{
    
    if(self.hintsNumber == 3){
        
        [self updateSpotLightWithPoint:CGPointMake(44, 358)];
        [self addHintArrowImage:@"intro_arrow_left_down.png" andArrowCenter:CGPointMake(SLIDER_ARROWCENTER_X, iPhone5?SLIDER_ARROWCENTER_Y_ip5:SLIDER_ARROWCENTER_Y_ip4) andAddPhotoName:AMLocalizedString(@"TUTORIAL_SLIDER_IMAGENAME", nil) andImageViewCenter:CGPointMake(SLIDER_ARROWCENTER_X+40, (iPhone5?SLIDER_ARROWCENTER_Y_ip5:SLIDER_ARROWCENTER_Y_ip4)-50)];
        
        
    }else if(self.hintsNumber == 2){
        
        [self updateSpotLightWithPoint:CGPointMake(160, 470)];
        [self addHintArrowImage:@"intro_arrow_right_down.png" andArrowCenter:CGPointMake(CAPTURE_ARROWCENTER_X, iPhone5?CAPTURE_ARROWCENTER_Y_ip5:CAPTURE_ARROWCENTER_Y_ip4) andAddPhotoName:AMLocalizedString(@"TUTORIAL_CAPTUREBTN_IMAGENAME", nil) andImageViewCenter:CGPointMake(CAPTURE_ARROWCENTER_X+30, (iPhone5?CAPTURE_ARROWCENTER_Y_ip5:CAPTURE_ARROWCENTER_Y_ip4)-90)];
        
        UIImageView *dashCircle = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tutorial_dashcircle.png"]];
        dashCircle.center = CGPointMake(160, iPhone5? 465:400);
        [self addSubview:dashCircle];

        
    }else{
        [self.superview removeFromSuperview];
        return;
    }
    
    self.hintsNumber--;
}

@end
