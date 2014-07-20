//
//  HaoCaptureButton.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "HaoCaptureButton.h"
#import <QuartzCore/QuartzCore.h>
#import "MRTextLayer.h"
#import "MRImageLayer.h"
#import "ImageCropView.h"


CGFloat const MRoundedButtonMaxValue = CGFLOAT_MAX;

#define M_MAX_CORNER_RADIUS MIN(CGRectGetWidth(self.bounds) / 2.0, CGRectGetHeight(self.bounds) / 2.0)
#define M_MAX_BORDER_WIDTH  M_MAX_CORNER_RADIUS
#define M_MAGICAL_VALUE     0.29

#if !__has_feature(objc_arc)
#error This file must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

#pragma mark - CGRect extend
static CGRect CGRectEdgeInset(CGRect rect, UIEdgeInsets insets){
    
    return CGRectMake(CGRectGetMinX(rect) + insets.left,
                      CGRectGetMinY(rect) + insets.top,
                      CGRectGetWidth(rect) - insets.left - insets.right,
                      CGRectGetHeight(rect) - insets.top - insets.bottom);
}


#pragma mark - MRoundedButton
@interface HaoCaptureButton ()

@property (nonatomic, strong)                   UIColor                 *backgroundColorCache;
@property (assign, getter = isTrackingInside)   BOOL                    trackingInside;
@property (nonatomic, strong)                   UIView                  *foregroundView;
@property (nonatomic, strong)                   MRTextLayer             *textLayer;
@property (nonatomic, strong)                   MRTextLayer             *detailTextLayer;
@property (nonatomic, strong)                   MRImageLayer            *imageLayer;


@property (strong,nonatomic) NSTimer *focusTimer;

@property (strong,nonatomic) UILongPressGestureRecognizer *longPress;

@property (nonatomic) BOOL usingLongPress;

@property (strong,nonatomic) CameraView *camView;

@property (nonatomic) CGPoint focusPoint;

@end

@implementation HaoCaptureButton

- (instancetype)initWithFrame:(CGRect)frame buttonStyle:(MRoundedButtonStyle)style
         appearanceIdentifier:(NSString *)identifier andCameraView:(UIView *)camView{
    
    self = [super initWithFrame:frame];
    if (self)
    {
        self.camView = (CameraView *)camView;
        
        self.layer.masksToBounds = YES;
        
        _mr_buttonStyle = style;
        _contentColor = self.tintColor;
        _foregroundColor = [UIColor whiteColor];
        _restoreSelectedState = YES;
        _trackingInside = NO;
        _cornerRadius = 0.0;
        _borderWidth = 0.0;
        _contentEdgeInsets = UIEdgeInsetsZero;
        
        self.foregroundView = [[UIView alloc] initWithFrame:CGRectNull];
        self.foregroundView.backgroundColor = self.foregroundColor;
        self.foregroundView.layer.masksToBounds = YES;
        [self addSubview:self.foregroundView];
        
        self.textLayer = [[MRTextLayer alloc] initWithFrame:CGRectNull];
        self.textLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.textLayer aboveSubview:self.foregroundView];
        
        self.detailTextLayer = [[MRTextLayer alloc] initWithFrame:CGRectNull];
        self.detailTextLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.detailTextLayer aboveSubview:self.foregroundView];
        
        self.imageLayer = [[MRImageLayer alloc] initWithFrame:CGRectNull];
        self.imageLayer.backgroundColor = self.contentColor;
        [self insertSubview:self.imageLayer aboveSubview:self.foregroundView];
        
        [self applyAppearanceForIdentifier:identifier];
        
        //Hao added long press
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
        _longPress.minimumPressDuration = 0.5f;
        [self addGestureRecognizer:_longPress];
        
    }
    
    return self;
}


- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)sender{
    
    if (sender.state == UIGestureRecognizerStateBegan){
        
        //self.selected = !self.selected;
        self.detailTextLabel.text = @"Focusing";
        
        
        _focusTimer = [NSTimer timerWithTimeInterval:3.0f target:self selector:@selector(startFocusLoop) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_focusTimer forMode:NSRunLoopCommonModes];
        NSLog(@"enable timer");
        
        self.usingLongPress = YES;
        
        ImageCropView *cropView = [self.camView getCropView];
        
        CGFloat focusCenterX = cropView.cropAreaInView.origin.x + cropView.cropAreaInView.size.width/2;
        CGFloat focusCenterY = cropView.cropAreaInView.origin.y + cropView.cropAreaInView.size.height/2;
        
        self.focusPoint = CGPointMake(focusCenterX, focusCenterY);
        
//        NSLog(@"x %f",cropView.cropAreaInView.origin.x);
//        NSLog(@"y %f",cropView.cropAreaInView.origin.y);
//        NSLog(@"w %f",cropView.cropAreaInView.size.width);
//        NSLog(@"h %f",cropView.cropAreaInView.size.height);
        
        NSLog(@"fx %f",focusCenterX);
        NSLog(@"fy %f",focusCenterY);
        
        
        [self.camView getCameraFocus:self.focusPoint];
    }
    else if (sender.state == UIGestureRecognizerStateChanged){
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded){
        [_focusTimer invalidate];
        NSLog(@"invalidate timer");
        self.selected = !self.selected;
        
        self.detailTextLabel.text = @"Capture";
        
        self.usingLongPress = NO;
        
        [self.camView captureBtnPressed:nil];
    }else if(sender.state == UIGestureRecognizerStateCancelled){
        
        [_focusTimer invalidate];
        NSLog(@"invalidate timer");
        self.selected = !self.selected;
        
        self.detailTextLabel.text = @"Capture";
        
        self.usingLongPress = NO;
    }
}

- (void)startFocusLoop
{
    NSLog(@"*** Focusing ***");
    [self.camView getCameraFocus:self.focusPoint];
}


- (CGRect)boxingRect
{
    CGRect internalRect = CGRectInset(self.bounds,
                                      self.layer.cornerRadius * M_MAGICAL_VALUE + self.layer.borderWidth,
                                      self.layer.cornerRadius * M_MAGICAL_VALUE + self.layer.borderWidth);
    return CGRectEdgeInset(internalRect, self.contentEdgeInsets);
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    CGFloat cornerRadius = self.layer.cornerRadius = MAX(MIN(M_MAX_CORNER_RADIUS, self.cornerRadius), 0);
    CGFloat borderWidth = self.layer.borderWidth = MAX(MIN(M_MAX_BORDER_WIDTH, self.borderWidth), 0);
    
    _borderWidth = borderWidth;
    _cornerRadius = cornerRadius;
    
    CGFloat layoutBorderWidth = borderWidth == 0.0 ? 0.0 : borderWidth - 0.1;
    self.foregroundView.frame = CGRectMake(layoutBorderWidth,
                                           layoutBorderWidth,
                                           CGRectGetWidth(self.bounds) - layoutBorderWidth * 2,
                                           CGRectGetHeight(self.bounds) - layoutBorderWidth * 2);
    self.foregroundView.layer.cornerRadius = cornerRadius - borderWidth;
    
    switch (self.mr_buttonStyle)
    {
        case MRoundedButtonImageWithSubtitle:
        default:
        {
            CGRect boxRect = [self boxingRect];
            
            CGFloat midX = (320-65)/2;
            CGFloat midY = (boxRect.size.height-65)/2;
            
            self.textLayer.frame = CGRectNull;
            self.imageLayer.frame = CGRectMake(midX,
                                               midY,
                                               65,
                                               65);
            self.detailTextLayer.frame = CGRectMake(boxRect.origin.x,
                                                    midY+40,
                                                    CGRectGetWidth(boxRect),
                                                    CGRectGetHeight(boxRect) * 0.2);
       }
            break;
    }
}

#pragma mark - Appearance
- (void)applyAppearanceForIdentifier:(NSString *)identifier{
    
    if (![identifier length]){
        return;
    }
    
    NSDictionary *appearanceProxy = [MRoundedButtonAppearanceManager appearanceForIdentifier:identifier];
    if (!appearanceProxy){
        return;
    }
    
    [appearanceProxy enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key];
    }];
}

#pragma mark - Fade animation
- (void)fadeInAnimation{
    
    [UIView animateWithDuration:0.2 animations:^{
        if (self.contentAnimateToColor)
        {
            self.textLayer.backgroundColor = self.contentAnimateToColor;
            self.detailTextLayer.backgroundColor = self.contentAnimateToColor;
            self.imageLayer.backgroundColor = self.contentAnimateToColor;
        }
        
        if (self.borderAnimateToColor &&
            self.foregroundAnimateToColor &&
            self.borderAnimateToColor == self.foregroundAnimateToColor)
        {
            self.backgroundColorCache = self.backgroundColor;
            self.foregroundView.backgroundColor = [UIColor clearColor];
            self.backgroundColor = self.borderAnimateToColor;
            return;
        }
        
        if (self.borderAnimateToColor)
        {
            self.layer.borderColor = self.borderAnimateToColor.CGColor;
        }
        
        if (self.foregroundAnimateToColor)
        {
            self.foregroundView.backgroundColor = self.foregroundAnimateToColor;
        }
    }];
}

- (void)fadeOutAnimation{
    
    [UIView animateWithDuration:0.2 animations:^{
        self.textLayer.backgroundColor = self.contentColor;
        self.detailTextLayer.backgroundColor = self.contentColor;
        self.imageLayer.backgroundColor = self.contentColor;
        
        if (self.borderAnimateToColor &&
            self.foregroundAnimateToColor &&
            self.borderAnimateToColor == self.foregroundAnimateToColor)
        {
            self.foregroundView.backgroundColor = self.foregroundColor;
            self.backgroundColor = self.backgroundColorCache;
            self.backgroundColorCache = nil;
            return;
        }
        
        self.foregroundView.backgroundColor = self.foregroundColor;
        self.layer.borderColor = self.borderColor.CGColor;
    }];
}

#pragma mark - Touchs
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *touchView = [super hitTest:point withEvent:event];
    if ([self pointInside:point withEvent:event])
    {
        return self;
    }
    return touchView;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
     NSLog(@"*********************** Hao begain tracking *******************************");
    
    self.trackingInside = YES;
    self.selected = !self.selected;
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    NSLog(@"*********************** Hao continue tracking *******************************");
    
    BOOL wasTrackingInside = self.trackingInside;
    self.trackingInside = [self isTouchInside];
    
    if (wasTrackingInside && !self.isTrackingInside){
        self.selected = !self.selected;
    }
    else if (!wasTrackingInside && self.isTrackingInside){
        self.selected = !self.selected;
    }
    
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    NSLog(@"*********************** Hao ended tracking *******************************");
    
    self.trackingInside = [self isTouchInside];
    if (self.isTrackingInside && self.restoreSelectedState){
        self.selected = !self.selected;
    }
    
    self.trackingInside = NO;
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event{
    
    NSLog(@"*********************** Hao canceled tracking *******************************");
    self.trackingInside = [self isTouchInside];
    if (self.isTrackingInside && self.restoreSelectedState){
        
        if(!self.usingLongPress)
            self.selected = !self.selected;
    }
    
    self.trackingInside = NO;
    [super cancelTrackingWithEvent:event];
}

#pragma mark - Setter and getters
- (void)setCornerRadius:(CGFloat)cornerRadius{
    if (_cornerRadius == cornerRadius){
        return;
    }
    _cornerRadius = cornerRadius;
    [self setNeedsLayout];
}

- (void)setBorderWidth:(CGFloat)borderWidth{
    if (_borderWidth == borderWidth){
        return;
    }
    _borderWidth = borderWidth;
    [self setNeedsLayout];
}

- (void)setBorderColor:(UIColor *)borderColor{
    _borderColor = borderColor;
    self.layer.borderColor = borderColor.CGColor;
}

- (void)setContentColor:(UIColor *)contentColor{
    _contentColor = contentColor;
    self.textLayer.backgroundColor = contentColor;
    self.detailTextLayer.backgroundColor = contentColor;
    self.imageLayer.backgroundColor = contentColor;
}

- (void)setForegroundColor:(UIColor *)foregroundColor{
    _foregroundColor = foregroundColor;
    self.foregroundView.backgroundColor = foregroundColor;
}

- (UILabel *)textLabel{
    return self.textLayer.textLabel;
}

- (UILabel *)detailTextLabel{
    return self.detailTextLayer.textLabel;
}

- (UIImageView *)imageView{
    return self.imageLayer.imageView;
}

- (void)setEnabled:(BOOL)enabled{
    [super setEnabled:enabled];
    [UIView animateWithDuration:0.2 animations:^{
        self.foregroundView.alpha = enabled ? 1.0 : 0.5;
    }];
}

- (void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected){
        [self fadeInAnimation];
    }
    else{
        [self fadeOutAnimation];
    }
}

@end
