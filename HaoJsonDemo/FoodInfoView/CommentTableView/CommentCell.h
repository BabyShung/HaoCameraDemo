//
//  CommentCell.h
//  DetailViewDemo
//
//  Created by Hao Zheng on 6/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

extern const CGFloat kCommentPaddingFromLeft;
extern const CGFloat kCommentPaddingFromRight;
extern const CGFloat KCommentTextFontSize;

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *likeCountLabel;
@property (nonatomic, strong) UILabel *dislikeCountLabel;

@property (nonatomic, strong) UIImageView *likeCountImageView;
@property (nonatomic, strong) UIImageView *dislikeCountImageView;

@property (nonatomic, strong) UIButton *likeButton;
@property (nonatomic, strong) UIButton *dislikeButton;
@end
