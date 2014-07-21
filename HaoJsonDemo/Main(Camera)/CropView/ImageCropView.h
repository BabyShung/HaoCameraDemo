//
//  ImageCropView.h
//  ImageCropView
//
//  Created by Hao Zheng on 5/21/14.
//
//

#import <UIKit/UIKit.h>
#import "ShadeView.h"
#import "ControlPointView.h"

@interface ImageCropView : UIView {
    
    ShadeView* shadeView;
    UIImageView* imageView;
    CGRect imageFrameInView;
    CGFloat imageScale;
    
    CGFloat controlPointSize;
    ControlPointView* topLeftPoint;
    ControlPointView* bottomLeftPoint;
    ControlPointView* bottomRightPoint;
    ControlPointView* topRightPoint;
    NSArray *PointsArray;
    UIColor* controlColor;

    UIView* cropAreaView;
    
    
    DragPoint dragPoint;
}

-(void)setImage:(UIImage*)image;

@property (nonatomic) CGFloat controlPointSize;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic) CGRect cropAreaInView;
@property (nonatomic) CGRect cropAreaInImage;
@property (nonatomic, readonly) CGFloat imageScale;
@property (nonatomic) CGFloat maskAlpha;
@property (nonatomic, retain) UIColor* controlColor;


@end


/************
 
 orientation
 
 ************/

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;

@end

