//
//  LanguageCell.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/19/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LanguageCell.h"
#import "ED_Color.h"
@implementation LanguageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

-(void)setup{
    self.layer.cornerRadius = 4;
    self.backgroundColor = [ED_Color cellBlackColor];
}


@end
