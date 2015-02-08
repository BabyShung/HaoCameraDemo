//
//  smallLayout.m
//  HaoPaper
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "smallLayout.h"

@implementation smallLayout

-(id)initWithCoder:(NSCoder *)aDecoder{
    
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (id)init
{
    if (self = [super init]){
        [self setup];
    }
    return self;
}

-(void)setup{
    self.itemSize = CGSizeMake(142, iPhone5? 185:155);
    
    CGFloat bottomOffset = 68;  // added by Yang WAN
    CGFloat top = (iPhone5 ? 383 - bottomOffset : 325 - bottomOffset);
    CGFloat left = 2, right = 2;
    CGFloat bottom =  bottomOffset;
    
    self.sectionInset = UIEdgeInsetsMake(top, left, bottom, right);
    self.minimumInteritemSpacing = 10.0f;
    self.minimumLineSpacing = 2.0f;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return NO;
}

@end
