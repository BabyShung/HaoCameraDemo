//
//  ControlPointView.h
//  ImageCropView
//
//  Created by Hao Zheng on 5/21/14.
//
//

#import <UIKit/UIKit.h>

@interface ControlPointView : UIView {
    CGFloat red, green, blue, alpha;
}

@property (nonatomic, retain) UIColor* color;

@end
