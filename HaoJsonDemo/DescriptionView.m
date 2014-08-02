//
//  DescriptionView.m
//  EdibleCameraApp
//
//  Created by MEI C on 7/21/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "DescriptionView.h"
#import "RQShineLabel.h"

#define DescriptionContentLabelHeight 45
#define DescriptionFontSize 18
#define DescriptionReadMoreFoneSize 15
#define DescriptionReadMoreButtonWidth 100
#define DescriptionReadMoreButtonHeight 40

static NSString *DescriptionFontName = @"HelveticaNeue-Light";

@interface DescriptionView ()

@property (strong,nonatomic) RQShineLabel *contentLabel;

@end


@implementation DescriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        [self loadControls];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self){
        [self loadControls];
    }
    return self;
}

-(void)loadControls
{
    _boundedContentWidth = [[UIScreen mainScreen] bounds].size.width;
    
    _contentLabel = [[RQShineLabel alloc] init];
    _contentLabel.numberOfLines = 0;
    _contentLabel.lineBreakMode =NSLineBreakByTruncatingTail;
    _contentLabel.text = @"";
    _contentLabel.font = [UIFont fontWithName:DescriptionFontName size:DescriptionFontSize];
    _contentLabel.backgroundColor = [UIColor clearColor];
    _contentLabel.textColor = [UIColor blackColor];
    
    _readMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _readMoreBtn.titleLabel.font = [UIFont fontWithName:DescriptionFontName size:DescriptionReadMoreFoneSize];
    [_readMoreBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    _readMoreBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    _readMoreBtn.backgroundColor = [UIColor clearColor];
    [_readMoreBtn addTarget:self action:@selector(readMoreBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [_readMoreBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    _readMoreBtn.enabled = YES;
    _readMoreBtn.hidden = YES;
    
    
    _transparentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _transparentBtn.backgroundColor = [UIColor clearColor];
    [_transparentBtn addTarget:self action:@selector(readMoreBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    _transparentBtn.enabled = YES;
    _transparentBtn.hidden = YES;
    
    [self addSubview:_contentLabel];
    [self addSubview:_readMoreBtn];
    [self addSubview:_transparentBtn];
    
}

-(NSString *)getContentText{
    return _contentLabel.text;
}

-(void) setContentText:(NSString *)contentText{

    CGRect expectedRect = [contentText boundingRectWithSize:CGSizeMake(_boundedContentWidth, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:DescriptionFontName size:DescriptionFontSize]}
                                                context:nil];
    
    //Text too long, show read more button
    if (expectedRect.size.height > DescriptionContentLabelHeight)
    {
        [_readMoreBtn setTitle:AMLocalizedString(@"FIV_READ_MORE", nil) forState:UIControlStateNormal];
        _transparentBtn.hidden = NO;
        _readMoreBtn.hidden = NO;
        self.frame = (CGRect){.origin = self.frame.origin, .size={self.frame.size.width, DescriptionContentLabelHeight+DescriptionReadMoreButtonHeight}};

    }
    else{
        //Text can be showed in the constraint rect
        //Change height accordingly
        _transparentBtn.hidden = YES;
        _readMoreBtn.hidden = YES;
        self.frame = (CGRect){.origin = self.frame.origin, .size={self.frame.size.width, expectedRect.size.height+DescriptionReadMoreButtonHeight}};

    }
    _contentLabel.text = contentText;
    [self.delegate DesciprionViewTextDidChanged];
    
}



-(void)setFrame:(CGRect)frame{
    
    NSLog(@"~~~~~~~~~~~~~+++++++++++++ DESCRIPTION SET FRAME+++++++++++++++~~~~~~~~~~~~~");
    [super setFrame:(CGRect){.origin =frame.origin, .size ={frame.size.width, MAX(DescriptionContentLabelHeight+DescriptionReadMoreButtonHeight, frame.size.height) } }];
    
    _contentLabel.frame = (CGRect){.origin =self.bounds.origin, .size ={self.frame.size.width, self.frame.size.height-DescriptionReadMoreButtonHeight} };
    _readMoreBtn.frame = CGRectMake(CGRectGetMaxX(_contentLabel.frame)-DescriptionReadMoreButtonWidth, CGRectGetMaxY(_contentLabel.frame), DescriptionReadMoreButtonWidth, DescriptionReadMoreButtonHeight);
    _transparentBtn.frame = _contentLabel.frame;

}

-(void)readMoreBtnPressed
{
    CGRect expectedRect = [self.contentText boundingRectWithSize:CGSizeMake(_boundedContentWidth, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                 attributes:@{NSFontAttributeName:[UIFont fontWithName:DescriptionFontName size:DescriptionFontSize]}
                                                    context:nil];
    if ([self.readMoreBtn.titleLabel.text isEqualToString:AMLocalizedString(@"FIV_READ_MORE", nil)])
    {
        [self.readMoreBtn setTitle:AMLocalizedString(@"FIV_READ_LESS", nil) forState:UIControlStateNormal];
        
        self.frame = (CGRect){.origin = self.frame.origin, .size={self.frame.size.width, expectedRect.size.height+DescriptionReadMoreButtonHeight}};
        
        
    }else
    {
        [self.readMoreBtn setTitle:AMLocalizedString(@"FIV_READ_MORE", nil) forState:UIControlStateNormal];
        
        self.frame = (CGRect){.origin = self.frame.origin, .size={self.frame.size.width, DescriptionContentLabelHeight+DescriptionReadMoreButtonHeight}};

        
    }
    [self.delegate DesciprionViewReadMoreFired];

}

-(void)shine{
    [_contentLabel shine];
}

-(void)config{
    _contentLabel.textColor = [UIColor blackColor];

}

-(void)resetData{
    [_readMoreBtn setTitle:@"" forState:UIControlStateNormal];
    _readMoreBtn.hidden = YES;
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
