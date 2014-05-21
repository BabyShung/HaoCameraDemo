//
//  ShadeView.m
//  ImageCropView
//
//  Created by Hao Zheng on 5/21/14.
//
//

#import "ShadeView.h"

@implementation ShadeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
    }
    return self;
}

- (void)setCropBorderColor:(UIColor *)_color {
    [_color getRed:&cropBorderRed green:&cropBorderGreen blue:&cropBorderBlue alpha:&cropBorderAlpha];
    [self setNeedsDisplay];
}

- (UIColor*)cropBorderColor {
    return [UIColor colorWithRed:cropBorderRed green:cropBorderGreen blue:cropBorderBlue alpha:cropBorderAlpha];
}

- (void)setCropArea:(CGRect)_clearArea {
    cropArea = _clearArea;
    [self setNeedsDisplay];
}

- (CGRect)cropArea {
    return cropArea;
}

- (void)setShadeAlpha:(CGFloat)_alpha {
    shadeAlpha = _alpha;
    [self setNeedsDisplay];
}

- (CGFloat)shadeAlpha {
    return shadeAlpha;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, rect);
    
    CGContextSetRGBFillColor(context, 0, 0, 0.05, self.shadeAlpha);
    CGContextFillRect(context, rect);
    
    CGContextClearRect(context, self.cropArea);
    
    CGContextSetRGBStrokeColor(context, cropBorderRed, cropBorderGreen, cropBorderBlue, cropBorderAlpha);
    CGContextSetLineWidth(context, 2);
    CGContextStrokeRect(context, self.cropArea);
    
}

@end

