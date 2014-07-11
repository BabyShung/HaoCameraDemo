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
#import "AppDelegate.h"
#import "BlurActionSheet.h"
#import "User.h"
#import "UIView+Toast.h"
#import "UIButton+Bootstrap.h"
#import "LoginViewController.h"


#define CROPVIEW_HEIGHT iPhone5?360:300

const NSString *collectionCellIdentity = @"Cell";
const CGFloat LeftMargin = 15.0f;
const CGFloat LeftContextMargin = 40.f;
const CGFloat TopContextMargin = 100.0f;
const CGFloat TopMargin = 25.0f;
static NSArray *colors;

@interface CardsViewController () <UICollectionViewDataSource,
UICollectionViewDelegate, MKTransitionCoordinatorDelegate>

@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;

@property (nonatomic, weak) IBOutlet UICollectionView *bottomCollectionView;

@property (strong,nonatomic) NSArray *settings;
@property (strong,nonatomic) NSArray *settingsImages;

@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) FBShimmeringView *shimmeringView;
@property (strong, nonatomic) RQShineLabel *descriptionLabel;

@property (strong, nonatomic) UIButton * previousPageBtn;

@property (strong,nonatomic) NSString *tempFeedbackText;

@property (nonatomic) NSUInteger assumedIndex;

@property (nonatomic) BOOL shouldSlideBack;

@property (strong, nonatomic) UIView * separatorLine;

@end

@implementation CardsViewController
- (void) doInits {
    
    colors = @[[UIColor colorWithRed:(0/255.0) green:(181/255.0) blue:(239/255.0) alpha:1],
               [UIColor colorWithRed:(150/255.0) green:(222/255.0) blue:(35/255.0) alpha:1],
               [UIColor colorWithRed:(255/255.0) green:(216/255.0) blue:(0/255.0) alpha:1],
               [UIColor colorWithRed:(0/255.0) green:(125/255.0) blue:(192/255.0) alpha:1],
               [UIColor colorWithRed:(253/255.0) green:(91/255.0) blue:(159/255.0) alpha:1],
               [UIColor colorWithRed:(233/255.0) green:(0/255.0) blue:(11/255.0) alpha:1]];
    
    self.settings = [NSArray arrayWithObjects:NSLocalizedString(@"CARD_SEARCH", nil),NSLocalizedString(@"CARD_FEEDBACK", nil),NSLocalizedString(@"CARD_ABOUT", nil),NSLocalizedString(@"CARD_LOGOUT", nil), nil];
    self.settingsImages = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"ED_search.png"],
                           [UIImage imageNamed:@"ED_feedback.png"],
                           [UIImage imageNamed:@"ED_about.png"],
                           [UIImage imageNamed:@"ED_logout.png"], nil];
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
    
    [self loadControls];
    
    User *user = [User sharedInstance];
    
    
    if(user.Uid == AnonymousUser){
        
        self.titleLabel.text = [NSString stringWithFormat: @"%@",NSLocalizedString(@"ANONYMOUS_HELLO", nil)];
        
        //init view to indicate login
        self.descriptionLabel.text = NSLocalizedString(@"NOT_LOGIN_REGISTERED_TEXT", nil);
        
        UIButton *registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(LeftContextMargin, 190, 240, 50)];
        [registerBtn addTarget:self action:@selector(PressedRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
        [registerBtn setTitle:NSLocalizedString(@"LOGIN_REGISTER_BUTTON_TEXT", nil) forState:UIControlStateNormal];
        [registerBtn successStyle];
        [self.view addSubview:registerBtn];
        

        
    }else{
        self.titleLabel.text = [NSString stringWithFormat: @"%@, %@",NSLocalizedString(@"Hello", nil),user.name];
        
        //show 
        self.descriptionLabel.text = NSLocalizedString(@"LOGGEDIN_CONTEXT_1", nil);
        self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    }
    
    [self.descriptionLabel sizeToFit];
}

-(void)PressedRegisterButton:(id)stuff{
    
    [User logout];
    
    [self transitionToLoginVC];
    
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.shimmeringView.shimmering){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shimmeringView.shimmering = NO;
        });
    }
    
    [self.descriptionLabel shine];
    
}

-(void)loadControls{
    
    //separator line
    _separatorLine = [[UIView alloc] initWithFrame:CGRectMake(10, CROPVIEW_HEIGHT, 300, 1)];
    _separatorLine.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_separatorLine];
    
    
    _previousPageBtn = [LoadControls createRoundedButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andCenter:CGPointMake(10+20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
    [_previousPageBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_previousPageBtn];
    
    
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.disableLeftEdgePan = YES;
    self.menuInteractor.delegate = self;
    
    
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
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22];
    self.titleLabel.textColor = [UIColor whiteColor];
    //self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    _shimmeringView.contentView = self.titleLabel;
    
    
    
    self.descriptionLabel = ({
        RQShineLabel *label = [[RQShineLabel alloc] initWithFrame:CGRectMake(LeftContextMargin, TopContextMargin, 270, 300)];
        label.numberOfLines = 0;
        label.text = @"";
        label.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:22.0];
        label.backgroundColor = [UIColor clearColor];
        //[label sizeToFit];

          //label.center = self.view.center;
        label.textColor = [UIColor whiteColor];
        label;
    });
    [self.view addSubview:self.descriptionLabel];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.bottomCollectionView) {
        NSIndexPath *centerCellIndex = [self.bottomCollectionView indexPathForItemAtPoint:CGPointMake(CGRectGetMidX(self.bottomCollectionView.bounds) , CGRectGetMidY(self.bottomCollectionView.bounds))];
        
        if(centerCellIndex.row != _assumedIndex){
            _assumedIndex = centerCellIndex.row;
            
            NSLog(@"did scroll to index: %d",(int)centerCellIndex.row);
        }
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
    cell.titleLabel.text = [self.settings objectAtIndex:indexPath.row];
    cell.backgroundColor = colors[indexPath.row%self.settings.count];
    cell.imageView.image = self.settingsImages[indexPath.row];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    _shouldSlideBack = YES;
    
    NSUInteger index = indexPath.row;
    
    if(index == 0){
        
        
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Search"] animated:YES];
        

        
    }else if(index == 1){
        IQFeedbackView *feedback = [[IQFeedbackView alloc] initWithTitle:NSLocalizedString(@"Feedback", nil) message:self.tempFeedbackText image:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) doneButtonTitle:NSLocalizedString(@"Send", nil)];
        [feedback setCanAddImage:NO];
        [feedback setCanEditText:YES];
        
        [feedback showInViewController:self completionHandler:^(BOOL isCancel, NSString *message, UIImage *image) {
            
            if(!isCancel){//sending feedback
                [User sendFeedBack:message andCompletion:^(NSError *err,BOOL success){
                    
                    if(success){
                        [self.view makeToast:NSLocalizedString(@"SUCCESS_FEEDBACK", nil)];
                        self.tempFeedbackText = @"";
                    }else{
                        [self.view makeToast:NSLocalizedString(@"FAIL_FEEDBACK", nil)];
                    }
                    
                    
                }];
                
                
            }else{
                //temporary save the text
                self.tempFeedbackText = message;
            }
            
            [feedback dismiss];
        }];
    }else if (index == 2){
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AboutUs"] animated:YES];
    }else if (index == 3){
        [self willLogout];
    }
    
}


-(void)willLogout{
    //show a confirm dialog
    BlurActionSheet *lrf =  [[BlurActionSheet alloc] initWithDelegate_cancelButtonTitle:NSLocalizedString(@"Cancel", nil)];
    
    lrf.blurRadius = 50.f;
    
    [lrf addButtonWithTitle:NSLocalizedString(@"Log out", nil) actionBlock:^{
        
        [User logout];

        [self transitionToLoginVC];
        
    }];
    
    [lrf show];
    
}

-(void)transitionToLoginVC{
    UIWindow *windooo = [[[UIApplication sharedApplication] delegate] window];
    UIViewController *fvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Start"];
    [UIView transitionWithView:windooo
                      duration:0.3
                       options:UIViewAnimationOptionCurveEaseOut
                    animations:^{
                        self.view.alpha = 0;
                    }
                    completion:^(BOOL success){
                        windooo.rootViewController = fvc;
                    }];
}


-(void)viewWillDisappear:(BOOL)animated{
    
    [self CardSlide:YES];
}

-(void)CardSlide:(BOOL)left{
    [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(left?0:[self.settings count]-1) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - MKTransitionCoordinatorDelegate Methods
- (UIViewController*) toViewControllerForInteractivePushFromPoint:(CGPoint)locationInWindow {
    //In this example we don't care where the user is pushing from
    NSLog(@"delegate get called");
    return [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
}


@end
