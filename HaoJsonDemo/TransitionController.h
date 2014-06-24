//
//  HATransitionController.h
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

@import UIKit;

@protocol TransitionControllerDelegate <NSObject>

- (void)interactionBeganAtPoint:(CGPoint)point;

@end


@interface TransitionController : NSObject  <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning, UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property (nonatomic) id <TransitionControllerDelegate> delegate;

@property (nonatomic) BOOL hasActiveInteraction;

@property (nonatomic) UINavigationController *nvc;

@property (nonatomic) UINavigationControllerOperation navigationOperation;

@property (nonatomic) UICollectionView *collectionView;



- (instancetype)initWithCollectionView:(UICollectionView*)collectionView;

@end
