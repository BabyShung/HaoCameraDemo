//
//  HAPaperCollectionViewController.m
//  Paper
//
//  Created by Heberti Almeida on 11/02/14.
//  Copyright (c) 2014 Heberti Almeida. All rights reserved.
//

#import "DetailViewController.h"
#import "TransitionLayout.h"

#define MAX_COUNT 3
#define CELL_ID @"CELL_ID"

@interface DetailViewController ()

@end


@implementation DetailViewController


-(void)viewDidLoad{
    
    [super viewDidLoad];
    NSLog(@"--------------- Large layout View did load ---------------");
}


//UICollectionViewDelegate method
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    NSLog(@"transitioning...");
    
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    
    return transitionLayout;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    
    // Adjust scrollView decelerationRate
    self.collectionView.decelerationRate = self.class != [DetailViewController class] ? UIScrollViewDecelerationRateNormal : UIScrollViewDecelerationRateFast;
}




- (id)initWithCollectionViewLayout:(UICollectionViewFlowLayout *)layout
{
    if (self = [super initWithCollectionViewLayout:layout])
    {
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CELL_ID];
        
        [self.collectionView setBackgroundColor:[UIColor clearColor]];
        
        NSLog(@"what the hell!!!");
        
    }
    return self;
}

//    #pragma mark - Hide StatusBar
//    - (BOOL)prefersStatusBarHidden
//    {
//        return YES;
//    }

// configure each collection cell: dequeue resuable
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor whiteColor];
    
    cell.layer.cornerRadius = 9;
    
    cell.clipsToBounds = YES;

    cell.backgroundView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Cell"]];
    
    //PS: backgroundView, SelectedBackgroundView, contentView
    
    return cell;
}

//count
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MAX_COUNT;
}

//section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewController*)nextViewControllerAtPoint:(CGPoint)point{
    return nil;
}



@end
