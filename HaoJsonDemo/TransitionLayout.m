//
//  HATransitionLayout.m
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "TransitionLayout.h"

static NSString *kOffsetH = @"offsetH";
static NSString *kOffsetV = @"offsetV";

@implementation TransitionLayout

// set the completion progress of the current transition.
- (void)setTransitionProgress:(CGFloat)transitionProgress
{
    [super setTransitionProgress:transitionProgress];
    
    // return the most recently set values for each key
    CGFloat offsetH = [self valueForAnimatedKey:kOffsetH];
    
    CGFloat offsetV = [self valueForAnimatedKey:kOffsetV];
    
    _offset = UIOffsetMake(offsetH, offsetV);
}

// called by the TransitionController class while updating its transition progress, animating
// the collection view items in an out of stack mode.
- (void)setOffset:(UIOffset)offset
{
    // store the floating-point values with our meaningful keys for our transition layout object
    [self updateValue:offset.horizontal forAnimatedKey:kOffsetH];
    
    [self updateValue:offset.vertical forAnimatedKey:kOffsetV];

    _offset = offset;
}

// return the layout attributes for all of the cells and views in the specified rectangle
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    
    for (UICollectionViewLayoutAttributes *currentAttribute in attributes)
    {
        
        CGPoint currentCenter = currentAttribute.center;
        CGFloat updateX =currentCenter.x + self.offset.horizontal;
        
        //Limit user's motion
        CGFloat updateY = MIN(MAX([[UIScreen mainScreen] bounds].size.height/2, currentCenter.y + self.offset.vertical), [[UIScreen mainScreen] bounds].size.height-190/2) ;
        currentAttribute.center = CGPointMake(updateX, updateY);

    }
    return attributes;
}



@end
