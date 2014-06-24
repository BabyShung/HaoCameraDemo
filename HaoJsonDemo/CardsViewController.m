//
//  FirstViewController.m
//  MyPolicyCard
//
//  Created by Hao Zheng on 6/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "CardsViewController.h"
#import "CardsCollectionCell.h"

#import "Carrier.h"

#import "FBShimmering.h"
#import "FBShimmeringView.h"
#import "RQShineLabel.h"

#import "MKTransitionCoordinator.h"


const NSString *collectionCellIdentity = @"Cell";
const CGFloat LeftMargin = 15.0f;
const CGFloat TopMargin = 25.0f;
static NSArray *colors;

@interface CardsViewController () <UICollectionViewDataSource,
    UICollectionViewDelegate, MKTransitionCoordinatorDelegate>

@property (weak, nonatomic) IBOutlet UILabel *currentCellHeader;
@property (weak, nonatomic) IBOutlet UILabel *policyLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *webLabel;

@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;


@property (nonatomic, weak) IBOutlet UICollectionView *bottomCollectionView;


@property (strong,nonatomic) NSArray *carriers;

@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) FBShimmeringView *shimmeringView;
@property (strong, nonatomic) RQShineLabel *descriptionLabel;

@end

@implementation CardsViewController
- (void) doInits {
    
    colors = @[[UIColor colorWithRed:(0/255.0) green:(181/255.0) blue:(239/255.0) alpha:1],
               [UIColor colorWithRed:(150/255.0) green:(222/255.0) blue:(35/255.0) alpha:1],
               [UIColor colorWithRed:(255/255.0) green:(216/255.0) blue:(0/255.0) alpha:1],
               [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(192/255.0) alpha:1],
               [UIColor colorWithRed:(253/255.0) green:(91/255.0) blue:(159/255.0) alpha:1],
               [UIColor colorWithRed:(233/255.0) green:(0/255.0) blue:(11/255.0) alpha:1]];
    
    Carrier *c1 = [[Carrier alloc]initWithPlan:@"aa" andPolicyNo:@[@"bb"] andPhoneNo:@"cc" andWeb:@"dd"];
    Carrier *c2 = [[Carrier alloc]initWithPlan:@"md" andPolicyNo:@[@"vv"] andPhoneNo:@"888.466.8673" andWeb:@"www.metlife.com"];
    Carrier *c3 = [[Carrier alloc]initWithPlan:@"vv" andPolicyNo:@[@"cc"] andPhoneNo:@"dd" andWeb:@"www.vsp.com"];
    Carrier *c4 = [[Carrier alloc]initWithPlan:@"ll" andPolicyNo:@[@"vv",@"cc"] andPhoneNo:@"800.423.2765" andWeb:@"www.dfs.com"];
    Carrier *c5 = [[Carrier alloc]initWithPlan:@"jh" andPolicyNo:@[@"ee"] andPhoneNo:@"800.395.1113" andWeb:@"sdfsdf"];
    Carrier *c6 = [[Carrier alloc]initWithPlan:@"fs" andPolicyNo:@[] andPhoneNo:@"925.956.0505" andWeb:@"sdf"];
    
    self.carriers = [NSArray arrayWithObjects:c1,c2,c3,c4,c5,c6, nil];
    
  

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInits];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.delegate = self;
    
    
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.bottomCollectionView registerClass:[CardsCollectionCell class] forCellWithReuseIdentifier:[collectionCellIdentity copy]];
    
    
    
    self.bottomCollectionView.clipsToBounds = NO;
    
    //first show
    Carrier *current = (Carrier*)[self.carriers firstObject];
    self.currentCellHeader.text = [NSString stringWithFormat:@"%@", current.plan];
    self.policyLabel.text = current.policyNumber.count==0?@"":current.policyNumber[0];
    self.phoneLabel.text = current.phoneNumber;
    self.webLabel.text = current.website;
    
    
    
    CGRect titleRect = CGRectMake(LeftMargin, TopMargin, self.view.bounds.size.width, 30);
    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:titleRect];
    self.shimmeringView.shimmering = YES;   //start shimmering
    self.shimmeringView.shimmeringBeginFadeDuration = 0.2;
    self.shimmeringView.shimmeringOpacity = 0.5;
    self.shimmeringView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.shimmeringView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    self.titleLabel.text = @"Hello, Hao";
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
    self.titleLabel.textColor = [UIColor whiteColor];
    //self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    _shimmeringView.contentView = self.titleLabel;
    
    
    
    self.descriptionLabel = ({
        RQShineLabel *label = [[RQShineLabel alloc] initWithFrame:CGRectMake(LeftMargin+32, CGRectGetHeight(self.titleLabel.frame)+ 64, 100, 300)];
        label.numberOfLines = 0;
        label.text = @"Plan\n\n\n\nPolicy No.\n\n\n\nPhone No.\n\n\n\nWebsite";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
        label.backgroundColor = [UIColor clearColor];
        [label sizeToFit];
        //label.center = self.view.center;
        label.textColor = [UIColor whiteColor];
        label;
    });
    [self.view addSubview:self.descriptionLabel];

    
    
    

    
}

-(void)viewDidAppear:(BOOL)animated{
    
    //let shine label shine
    [self.descriptionLabel shine];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.shimmeringView.shimmering = NO;
    });
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bottomCollectionView) {
        NSIndexPath *centerCellIndex = [self.bottomCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.bottomCollectionView.bounds) , CGRectGetMidY(self.bottomCollectionView.bounds))];
        
        
        Carrier *current = (Carrier*)[self.carriers objectAtIndex:centerCellIndex.row];
        self.currentCellHeader.text = [NSString stringWithFormat:@"%@", current.plan];
        self.policyLabel.text = current.policyNumber.count==0?@"":current.policyNumber[0];
        self.phoneLabel.text = current.phoneNumber;
        self.webLabel.text = current.website;
        
        
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.carriers count];

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        CardsCollectionCell *cell = (CardsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[collectionCellIdentity copy] forIndexPath:indexPath];
        //cell.imageView = ((DECellData*)self.bottomCVDataSource[indexPath.item]).cellImageView;
    
        cell.titleLabel.text = ((Carrier*)[self.carriers objectAtIndex:indexPath.row]).plan;
        cell.backgroundColor = colors[indexPath.row%self.carriers.count];
    

        
        return cell;

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"did sssss");
    
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Register"] animated:YES];
    
}


- (IBAction)clickAndScroll:(id)sender {
    
    NSLog(@"xxx");
    
    [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
}

#pragma mark - MKTransitionCoordinatorDelegate Methods
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow {
    //In this example we don't care where the user is pushing from
    NSLog(@"delegate get called");
    return [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
