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
    self.itemSize = CGSizeMake(142, 190);
    self.sectionInset = UIEdgeInsetsMake((iPhone5 ? 378 : 288), 2, 0, 2);
    self.minimumInteritemSpacing = 10.0f;
    self.minimumLineSpacing = 2.0f;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    return YES;
}

@end