//
//  FirstViewController.m
//  MyPolicyCard
//
//  Created by Hao Zheng on 6/18/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "CardsViewController.h"
#import "CardsCollectionCell.h"

#import "ED_Color.h"
#import "FBShimmering.h"
#import "FBShimmeringView.h"
#import "RQShineLabel.h"
#import "LoadControls.h"
#import "MKTransitionCoordinator.h"
#import "IQFeedbackView.h"

#import "BlurActionSheet.h"


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

@property (strong,nonatomic) NSArray *settings;

@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) FBShimmeringView *shimmeringView;
@property (strong, nonatomic) RQShineLabel *descriptionLabel;

@property (strong, nonatomic) UIButton * previousPageBtn;

@property (nonatomic) int assumedIndex;

@end

@implementation CardsViewController
- (void) doInits {
    
    
    
    
    colors = @[[UIColor colorWithRed:(0/255.0) green:(181/255.0) blue:(239/255.0) alpha:1],
               [UIColor colorWithRed:(150/255.0) green:(222/255.0) blue:(35/255.0) alpha:1],
               [UIColor colorWithRed:(255/255.0) green:(216/255.0) blue:(0/255.0) alpha:1],
               [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(192/255.0) alpha:1],
               [UIColor colorWithRed:(253/255.0) green:(91/255.0) blue:(159/255.0) alpha:1],
               [UIColor colorWithRed:(233/255.0) green:(0/255.0) blue:(11/255.0) alpha:1]];
    
    self.settings = [NSArray arrayWithObjects:@"Search",@"Feedback",@"About",@"Logout", nil];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self doInits];
    }
    return self;
}

- (void) previousPagePressed:(id)sender {
    [self.settingDelegate slideToPreviousPage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //UICollectionViewFlowLayout *layout = (id) self.bottomCollectionView.collectionViewLayout;
    //layout.itemSize = self.bottomCollectionView.frame.size;
    
    
    
    _previousPageBtn = [LoadControls createCameraButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andCenter:CGPointMake(10+20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20)];
     [_previousPageBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_previousPageBtn];
    
    
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.disableLeftEdgePan = YES;
    self.menuInteractor.delegate = self;
    
    
    //self.navigationController.view.clipsToBounds = NO;
    
    //self.navigationController.navigationBarHidden = YES;
    
    [self.bottomCollectionView registerClass:[CardsCollectionCell class] forCellWithReuseIdentifier:[collectionCellIdentity copy]];
    
    self.bottomCollectionView.clipsToBounds = NO;
    
    //first show

    
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
    
    
    
//    self.descriptionLabel = ({
//        RQShineLabel *label = [[RQShineLabel alloc] initWithFrame:CGRectMake(LeftMargin+32, CGRectGetHeight(self.titleLabel.frame)+ 64, 100, 300)];
//        label.numberOfLines = 0;
//        label.text = @"Plan\n\n\n\nPolicy No.\n\n\n\nPhone No.\n\n\n\nWebsite";
//        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0];
//        label.backgroundColor = [UIColor clearColor];
//        [label sizeToFit];
//        //label.center = self.view.center;
//        label.textColor = [UIColor whiteColor];
//        label;
//    });
//    [self.view addSubview:self.descriptionLabel];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    //let shine label shine
    //[self.descriptionLabel shine];
    
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
        
        if(centerCellIndex.row != _assumedIndex){
            _assumedIndex = centerCellIndex.row;
            
            NSLog(@"did scroll to index: %d",centerCellIndex.row);
        }
        
        
//        Carrier *current = (Carrier*)[self.carriers objectAtIndex:centerCellIndex.row];
//        self.currentCellHeader.text = [NSString stringWithFormat:@"%@", current.plan];
//        self.policyLabel.text = current.policyNumber.count==0?@"":current.policyNumber[0];
//        self.phoneLabel.text = current.phoneNumber;
//        self.webLabel.text = current.website;
        
    }
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.settings count];

}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
        CardsCollectionCell *cell = (CardsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[collectionCellIdentity copy] forIndexPath:indexPath];
        //cell.imageView = ((DECellData*)self.bottomCVDataSource[indexPath.item]).cellImageView;
    
        cell.titleLabel.text = [self.settings objectAtIndex:indexPath.row];
        cell.backgroundColor = colors[indexPath.row%self.settings.count];
    

        
        return cell;

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger index = indexPath.row;
    
    if(index == 0){
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Search"] animated:YES];
    }else if(index == 1){
        IQFeedbackView *feedback = [[IQFeedbackView alloc] initWithTitle:@"Feedback" message:nil image:nil cancelButtonTitle:@"Cancel" doneButtonTitle:@"Send"];
        [feedback setCanAddImage:NO];
        [feedback setCanEditText:YES];
        
        [feedback showInViewController:self completionHandler:^(BOOL isCancel, NSString *message, UIImage *image) {
            [feedback dismiss];
        }];
    }else if (index == 2){
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Register"] animated:YES];
    }else if (index == 3){
        [self willLogout];
    }
    
}


-(void)willLogout{
    //show a confirm dialog
    BlurActionSheet *lrf =  [[BlurActionSheet alloc] initWithDelegate_cancelButtonTitle:@"Cancel"];
    
    lrf.blurRadius = 50.f;
    
    [lrf addButtonWithTitle:@"Log Out" actionBlock:^{
        
        /************************
         
         log out release things
         
         ************************/
       
        NSLog(@"click log out");
    }];
    
    [lrf show];
    
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [self clickAndScroll:nil];
}

- (IBAction)clickAndScroll:(id)sender {
    
    [self CardSlide:YES];
}

-(void)CardSlide:(BOOL)left{
    [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(left?0:1) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}


#pragma mark - MKTransitionCoordinatorDelegate Methods
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow {
    //In this example we don't care where the user is pushing from
    NSLog(@"delegate get called");
    return [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
}

@end