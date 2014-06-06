//
//  LoadControls.h
//  EdibleCameraApp
//
//  Created by MEI C on 5/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoadControls : NSObject

-(UIImageView *)createImageViewWithRect:(CGRect)rect;
-(UILabel *)createLabelWithRect:(CGRect)rect;
-(UITextView *)createTextViewWithRect:(CGRect)rect;

@end