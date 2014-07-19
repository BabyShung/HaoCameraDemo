//
//  CommentCell.m
//  DetailViewDemo
//
//  Created by Hao Zheng on 6/17/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "CommentCell.h"
#import "UIFont+SecretFont.h"

@implementation CommentCell {
    NSInteger _likeCount;
    NSInteger _dislikeCount;
}
const CGFloat kCommentPaddingFromTop = 4.0f;
const CGFloat kCommentPaddingFromLeft = 10.0f;
const CGFloat kCommentPaddingFromRight = 8.0f;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 35, 35)];
        // Go Toronto!
        self.iconView.image =[UIImage imageNamed:@"bluejay.jpg"];
        self.iconView.layer.cornerRadius = CGRectGetWidth(self.iconView.frame) / 2.0f;
        self.iconView.layer.masksToBounds = YES;
        [self addSubview:self.iconView];
        
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.textColor = [UIColor blackColor];
        self.commentLabel.textAlignment = NSTextAlignmentLeft;
        self.commentLabel.font = [UIFont fontWithName:@"Heiti TC" size:14.f];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.frame = (CGRect){.origin = {CGRectGetMinX(self.iconView.frame) + CGRectGetWidth(self.iconView.frame) + kCommentPaddingFromLeft, CGRectGetMinY(self.iconView.frame) + kCommentPaddingFromTop}};
        [self addSubview:self.commentLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font = [UIFont fontWithName:@"Heiti TC" size:12.f];
        self.timeLabel.numberOfLines = 1;
        [self addSubview:self.timeLabel];
        
        //Hao
        self.likeButton = [self createLikeButton_frame:CGRectMake(250, CGRectGetMinY(self.commentLabel.frame) + 5, 18, 18) andTagNumber:1];
        self.likeButton.hidden = YES;
        [self addSubview:self.likeButton];
        
        self.dislikeButton = [self createLikeButton_frame:CGRectMake(290, CGRectGetMinY(self.commentLabel.frame) + 5, 18, 18) andTagNumber:0];
        self.dislikeButton.hidden = YES;
        [self addSubview:self.dislikeButton];
        
        self.likeCountLabel = [[UILabel alloc] init];
        self.likeCountLabel.numberOfLines = 1;
        self.likeCountLabel.textColor = [UIColor grayColor];
        self.likeCountLabel.textAlignment = NSTextAlignmentLeft;
        self.likeCountLabel.font = [UIFont fontWithName:@"Heiti TC" size:12.f];
        self.likeCountLabel.hidden = YES;
        [self addSubview:self.likeCountLabel];
        
        self.likeCountImageView = [[UIImageView alloc] init];
        self.likeCountImageView.image = [UIImage imageNamed:@"like_greyIcon.png"];
        self.likeCountImageView.hidden = YES;
        [self addSubview:self.likeCountImageView];
        
        

    }
    return self;
}

- (void)likeButtonSelected:(UIButton*)sender {
    
    if(sender.tag == 1){
    
        self.likeButton.selected = !self.likeButton.selected;
        if (self.likeButton.selected) {
            _likeCount++;
        } else {
            _likeCount--;
        }
        self.likeCountLabel.text = [NSString stringWithFormat:@"%d",(int)_likeCount];
        [self.likeCountLabel sizeToFit];
        self.likeCountImageView.hidden = _likeCount <= 0;
        self.likeCountLabel.hidden = _likeCount <= 0;
    }else{
        self.dislikeButton.selected = !self.dislikeButton.selected;
        if (self.dislikeButton.selected) {
            _dislikeCount++;
        } else {
            _dislikeCount--;
        }
        self.dislikeCountLabel.text = [NSString stringWithFormat:@"%d",(int)_dislikeCount];
        [self.dislikeCountLabel sizeToFit];
        self.dislikeCountImageView.hidden = _dislikeCount <= 0;
        self.dislikeCountLabel.hidden = _dislikeCount <= 0;
    }
}

-(UIButton*)createLikeButton_frame:(CGRect)frame andTagNumber:(NSUInteger)number{
    UIButton *btn = [[UIButton alloc] init];
    // Hardcode the x value and size for simplicity
    btn.frame = frame;
    btn.tag = number;
    [btn setImage:[UIImage imageNamed:@"likeButton_unselected.png"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"likeButton_selected.png"] forState:UIControlStateSelected];
    [btn setImage:[UIImage imageNamed:@"likeButton_highlighted.png"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(likeButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


@end
