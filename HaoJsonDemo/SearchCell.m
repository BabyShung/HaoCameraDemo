//
//  SearchCell.m
//  SSSearchBarExample
//
//  Created by Hao Zheng on 7/2/14.
//  Copyright (c) 2014 Simon Gislen. All rights reserved.
//

#import "SearchCell.h"
#import "ED_Color.h"

@implementation SearchCell

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
