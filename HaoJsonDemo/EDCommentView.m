//
//  EDCommentView.m
//  EdibleCameraApp
//
//  Created by MEI C on 7/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "EDCommentView.h"

#define CommentMaxLength 150

#define CommentTextViewHeight 165.f
#define CommentViewTopMargin 26.f
#define CommentCloseBtnWidth 60.f
#define CommentTitleHeight 55.f
#define CommentRateViewHeight 65.f
#define CommentRateViewWidth 260.f
#define CommentLeftMargin 10.f
#define CommentTextCountLabelHeight 40.f
#define CommentTextCountLabelWidth 80.f

#define CommentTitleFontSize 17.f
#define CommentTextFontSize 18.f

#define CommentDefaultStars 3

@interface EDCommentView()

@property (strong,nonatomic) UILabel *countLabel;

@property (strong,nonatomic) NSMutableString *countStr;

@end

@implementation EDCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //_fid = fid;
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(frame.origin.x+CommentLeftMargin, frame.origin.y+CommentViewTopMargin, CGRectGetWidth(frame)-CommentCloseBtnWidth, CommentTitleHeight)];
        _titleLabel.numberOfLines = 1;
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:CommentTitleFontSize];
        _titleLabel.textColor = [UIColor whiteColor];
        
        _rateView = [[DXStarRatingView alloc] initWithFrame:CGRectMake((frame.size.width - CommentRateViewWidth+CommentLeftMargin)/2, CGRectGetMaxY(_titleLabel.frame), CommentRateViewWidth,CommentRateViewHeight)];
        
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(CommentLeftMargin, CGRectGetMaxY(_rateView.frame), frame.size.width - CommentLeftMargin*2, CommentTextViewHeight)];
        _textView.textColor = [UIColor blackColor];
        _textView.editable = YES;
        _textView.font = [UIFont systemFontOfSize:CommentTextFontSize];
        [_textView setReturnKeyType:UIReturnKeySend];
        _textView.delegate = self;
        [_textView becomeFirstResponder];
        

        _countStr = [NSMutableString stringWithFormat:@"%d",(int)(CommentMaxLength-_textView.text.length)];

        _countLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_textView.frame)-CommentTextCountLabelWidth, CGRectGetMaxY(_textView.frame)-CommentTextCountLabelHeight, CommentTextCountLabelWidth, CommentTextCountLabelHeight)];
        _countLabel.textColor = [UIColor lightGrayColor];
        _countLabel.text =_countStr;
        _countLabel.textAlignment = NSTextAlignmentRight;
        

        
        [self addSubview:_titleLabel];
        [self addSubview:_textView];
        [self addSubview:_rateView];
        [self addSubview:_countLabel];
        
    }
    
    return self;
}


-(NSUInteger)getStars{
    NSLog(@"+++++++++ EDCOMMENT ++++++++++++++ GET %d stars",(int)[_rateView currentStar]);
    return [_rateView currentStar];
}

- (void)setWithComment:(Comment *)comment{
    if (comment) {
        _textView.text = comment.text;
        [self textViewDidChange:_textView];
        [_rateView setStars:(int)comment.rate];
    }else{
        [_rateView setStars:CommentDefaultStars];
    }
}

- (void)setTitleWithFood:(NSString *)foodTitle{
    _titleLabel.text = [NSString stringWithFormat:@"%@ %@",AMLocalizedString(@"FIV_CMTV_TITLE", nil),foodTitle];
}
#pragma mark - TextView Delegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    //User press enter, send the comment
    if ([text isEqualToString:@"\n"]) {
        if ([_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length  == 0)
        {
            [self makeToast:AMLocalizedString(@"EMPTY_COMMENT", nil) duration:0.5 position:@"center"];
        }
        else if(_textView.text.length > CommentMaxLength)
        {
            [self makeToast:AMLocalizedString(@"COMMENT_TOO_LONG", nil) duration:0.5 position:@"center"];
        }
        else{
            
            NSLog(@"+++++++++++++++ EDCOMMENT VIEW +++++++++++ : RETURNED");
            [self.delegate EDCommentView:self KeyboardReturnedWithStars:[_rateView currentStar]];
        }
        return NO;
    }
    return YES;

}

-(void)textViewDidChange:(UITextView *)textView
{
    NSLog(@"+++++++++++++ EDCOMMENT ++++++++++++++++++ : Text Change to %@!",textView.text);

//    if ([_textView.text characterAtIndex:MAX((_textView.text.length-1), 0)] =='\n')
//    {
//        _textView.text = [_textView.text substringToIndex:MAX((_textView.text.length-1), 0)];
//        if ([_textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length  == 0)
//        {
//            [self makeToast:AMLocalizedString(@"EMPTY_COMMENT", nil) duration:0.5 position:@"center"];
//        }
//        else if(_textView.text.length > CommentMaxLength)
//        {
//            [self makeToast:AMLocalizedString(@"COMMENT_TOO_LONG", nil) duration:0.5 position:@"center"];
//        }
//        else{
//            
//            NSLog(@"+++++++++++++++ EDCOMMENT VIEW +++++++++++ : RETURNED");
//            [self.delegate EDCommentView:self KeyboardReturnedWithStars:[_rateView currentStar]];
//        }
//        return;
//        
//    }
    if (textView.text.length<CommentMaxLength) {
        _countLabel.textColor = [UIColor lightGrayColor];
        
    }
    else{
        _countLabel.textColor = [UIColor redColor];
    }
    [_countStr setString:@""];
    [_countStr appendFormat:@"%i",(int)(CommentMaxLength - textView.text.length)];
    NSLog(@"+++++++++++ EDCOMMENT ++++++++++++++ : WORD COUNT %@",_countStr);
    _countLabel.text =_countStr;
    
    
}
-(void)close{
    
    
    /*******     Clean Up all controllers!!!!! *******/
    [_titleLabel removeFromSuperview];
    [_rateView removeFromSuperview];
    [_textView removeFromSuperview];
    [_countLabel removeFromSuperview];
    
    [super close];
    //[self removeFromSuperview];
    
    //[self.delegate EDCommentViewDidClosed];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
