//
//  EDCommentView.h
//  EdibleCameraApp
//
//  Created by MEI C on 7/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HATransparentView.h"
#import "DXStarRatingView.h"
#import "UIView+Toast.h"
#import "LocalizationSystem.h"
#import "Comment.h"
#import "User.h"

@protocol EDCommentViewDelegate <HATransparentViewDelegate>
@required
//Fired after text checked and return button hit
-(void) EDCommentView:(HATransparentView *)edCommentView KeyboardReturnedWithStars:(NSUInteger)stars;

@end

@interface EDCommentView : HATransparentView <UITextViewDelegate>

@property (nonatomic, assign) id<EDCommentViewDelegate> delegate;

@property (strong,nonatomic) UILabel *titleLabel;

@property (strong,nonatomic) DXStarRatingView *rateView;

@property (nonatomic,readonly,getter = getStars) NSUInteger stars;

@property (strong,nonatomic) UITextView *textView;

//@property (nonatomic) NSUInteger fid;

- (id)initWithFrame:(CGRect)frame;

- (void)setWithComment:(Comment *)comment;

- (void)setTitleWithFood:(NSString *)foodTitle;

@end


