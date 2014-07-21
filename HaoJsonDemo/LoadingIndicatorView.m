//
//  LoadingIndicatorView.m
//  EdibleCameraApp
//
//  Created by MEI C on 7/14/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LoadingIndicatorView.h"

static NSString *LoadingBtnTextFont = @"HelveticaNeue-Light";

#define LoadingBtnFontSize 18


@implementation LoadingIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _loadingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loadingBtn.frame = frame;
        [_loadingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_loadingBtn setAlpha:0.5];
        _loadingBtn.titleLabel.font = [UIFont fontWithName:LoadingBtnTextFont size:LoadingBtnFontSize];
        _loadingBtn.backgroundColor = [UIColor grayColor];
        [_loadingBtn addTarget:self action:@selector(loadingBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_loadingBtn];
    }
    return self;
}

-(BOOL)isLoading
{
    if ([_loadingBtn.titleLabel.text isEqualToString:AMLocalizedString(@"FIV_LOADING_MSG", nil)]) {
        return YES;
    }
    return NO;
}
-(BOOL)isFailed
{
    if ([_loadingBtn.titleLabel.text isEqualToString:AMLocalizedString(@"FIV_LOADING_FAIL", nil)]) {
        return YES;
    }
    return NO;
}

-(BOOL)shouldBeHidden{
    if (self.isLoading || self.isFailed) {
        return NO;
    }
    return YES;
}

-(void)showLoadingMsg
{
    self.loadingBtn.enabled = NO;
    
    [self.loadingBtn setTitle:AMLocalizedString(@"FIV_LOADING_MSG", nil) forState:UIControlStateNormal];
    
}

-(void)showFailureMsg
{
    self.loadingBtn.enabled = YES;

    [self.loadingBtn setTitle:AMLocalizedString(@"FIV_LOADING_FAIL", nil) forState:UIControlStateNormal];

}

-(void)hide{
    [self.loadingBtn setTitle:@"" forState:UIControlStateNormal];
    NSLog(@"_____________________________Loading indicator hide");
    self.loadingBtn.enabled = NO;
    self.loadingBtn.hidden = YES;
    self.hidden = YES;
}

-(void)loadingBtnPressed{
    [self.delegate LoadingIndicatorFireReLoad];

}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.loadingBtn.frame = self.frame;
    NSLog(@"++++++++++++ LOADING INDICATOR ++++++++++++++ : should hide %i",self.shouldBeHidden);
    
    if (self.frame.size.height < [[UIScreen mainScreen] bounds].size.height ) {
        self.loadingBtn.hidden = YES;
        self.hidden = YES;
    }
    else if(!self.shouldBeHidden){
        self.loadingBtn.hidden = NO;
        self.hidden = NO;
    }
}

-(void)removeFromSuperview{
    [self.loadingBtn removeFromSuperview];

    [super removeFromSuperview];
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
