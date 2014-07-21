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
#import "User.h"
#import "UIView+Toast.h"
#import "UIButton+Bootstrap.h"
#import "IPDashedLineView.h"
#import "Flurry.h"
#import "LocalizationSystem.h"
#import "GeneralControl.h"
#import "introContainer.h"

#define CROPVIEW_HEIGHT iPhone5?358:298

const NSString *collectionCellIdentity = @"Cell";
const CGFloat LeftMargin = 15.0f;
const CGFloat LeftContextMargin = 40.f;
const CGFloat TopContextMargin = 100.0f;
const CGFloat TopMargin = 25.0f;
static NSArray *colors;

@interface CardsViewController () <UICollectionViewDataSource,
UICollectionViewDelegate>

@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;

@property (nonatomic, weak) IBOutlet UICollectionView *bottomCollectionView;

@property (nonatomic,strong) UIButton *registerBtn;

@property (strong,nonatomic) NSArray *profileOptions;
@property (strong,nonatomic) NSArray *profileOptionsImages;

@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) FBShimmeringView *shimmeringView;
@property (strong, nonatomic) RQShineLabel *descriptionLabel;

@property (strong, nonatomic) UIButton * previousPageBtn;

@property (strong,nonatomic) NSString *tempFeedbackText;

@property (strong, nonatomic) UIView * separatorLine;

@property (nonatomic) NSInteger selected;

@end

@implementation CardsViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self doInits];
    
    [self loadControls];
    
    [self checkUserStatusAtProfileBoard];

}

- (void) doInits {
    
    colors = @[[ED_Color cardLightBlue],[ED_Color cardLightGreen],[ED_Color cardMediumBlue],[ED_Color cardLightYellow]];
    self.profileOptions = [NSArray arrayWithObjects:
                     AMLocalizedString(@"CARD_SEARCH", nil),
                     AMLocalizedString(@"CARD_FEEDBACK",nil),
                     AMLocalizedString(@"CARD_SETTING",nil),
                     AMLocalizedString(@"CARD_LOGOUT", nil), nil];
    self.profileOptionsImages = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"EDB_search.png"],
                           [UIImage imageNamed:@"EDB_feedback.png"],
                           [UIImage imageNamed:@"EDB_settings.png"],
                           [UIImage imageNamed:@"EDB_logout.png"], nil];
}

-(void)checkUserStatusAtProfileBoard{
    User *user = [User sharedInstance];
 
    if(user.Uid == AnonymousUser){
        
        self.titleLabel.text = [NSString stringWithFormat: @"%@",AMLocalizedString(@"ANONYMOUS_HELLO", nil)];
        
        //init view to indicate login
        self.descriptionLabel.text = AMLocalizedString(@"NOT_LOGIN_REGISTERED_TEXT", nil);
        
       self.registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(LeftContextMargin, 190, 240, 50)];
        [self.registerBtn addTarget:self action:@selector(PressedRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.registerBtn setTitle:AMLocalizedString(@"LOGIN_REGISTER_BUTTON_TEXT", nil) forState:UIControlStateNormal];
        [self.registerBtn successStyle];
        [self.view addSubview:self.registerBtn];
        
        
    }else{
        self.titleLabel.text = [NSString stringWithFormat: @"%@, %@",AMLocalizedString(@"Hello", nil),user.name];
        
        //show
        self.descriptionLabel.text = AMLocalizedString(@"LOGGEDIN_CONTEXT_1", nil);
        self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        
    }
    
    [self.descriptionLabel sizeToFit];
}


- (void) previousPagePressed:(id)sender {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                        (unsigned long)NULL), ^(void) {
      [self.settingDelegate slideToPreviousPage];
    });
}

-(void)PressedRegisterButton:(id)stuff{

    [User logout];
    [GeneralControl transitionToVC:self withToVCStoryboardId:@"Start" withDuration:0.4];
}

-(void)viewDidAppear:(BOOL)animated{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        if(self.shimmeringView.shimmering){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.shimmeringView.shimmering = NO;
            });
            [self.descriptionLabel shine];
        }
    });
}

-(void)loadControls{
    
    //separator line
    IPDashedLineView *appearance = [IPDashedLineView appearance];
    [appearance setLineColor:[UIColor whiteColor]];
    [appearance setLengthPattern:@[@12, @4]];
    IPDashedLineView *dash0 = [[IPDashedLineView alloc] initWithFrame:CGRectMake(10, CROPVIEW_HEIGHT, 300, 1)];
    [self.view addSubview:dash0];
    
    
    _previousPageBtn = [LoadControls createRoundedBackButton];
    [_previousPageBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_previousPageBtn];
    
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.disableLeftEdgePan = NO;
    self.menuInteractor.disableRightEdgePan = YES;
    self.menuInteractor.transitionInvolvingCamera = YES;
    
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

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.profileOptions count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CardsCollectionCell *cell = (CardsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[collectionCellIdentity copy] forIndexPath:indexPath];
    cell.titleLabel.text = [self.profileOptions objectAtIndex:indexPath.row];
    cell.backgroundColor = colors[indexPath.row%self.profileOptions.count];
    cell.imageView.image = self.profileOptionsImages[indexPath.row];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUInteger index = indexPath.row;
    
    if(index == 0){
        [Flurry logEvent:@"Index_0_Search"];
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Search"] animated:YES];
    }else if(index == 1){
        
        [Flurry logEvent:@"Index_1_Feedback"];
        
        IQFeedbackView *feedback = [[IQFeedbackView alloc] initWithTitle:AMLocalizedString(@"Feedback", nil) message:self.tempFeedbackText image:nil cancelButtonTitle:AMLocalizedString(@"Cancel", nil) doneButtonTitle:AMLocalizedString(@"Send", nil)];
        [feedback setCanAddImage:NO];
        [feedback setCanEditText:YES];
        
        [feedback showInViewController:self completionHandler:^(BOOL isCancel, NSString *message, UIImage *image) {
            
            if(!isCancel){//sending feedback
                [User sendFeedBack:message andCompletion:^(NSError *err,BOOL success){
                    
                    if(success){
                        [self.view makeToast:AMLocalizedString(@"SUCCESS_FEEDBACK", nil)];
                        self.tempFeedbackText = @"";
                    }else{
                        [self.view makeToast:AMLocalizedString(@"FAIL_FEEDBACK", nil)];
                    }
                    
                }];
            }else{
                //temporary save the text
                self.tempFeedbackText = message;
            }
            [feedback dismiss];
        }];
    }else if (index == 2){
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"] animated:YES];
    }else if (index == 3){
        [Flurry logEvent:@"Index_3_Logout"];
        [self willLogout];
    }
}


-(void)willLogout{
    //show a confirm dialog
    BlurActionSheet *lrf =  [[BlurActionSheet alloc] initWithDelegate_cancelButtonTitle:AMLocalizedString(@"Cancel", nil)];
    lrf.blurRadius = 50.f;
    [lrf addButtonWithTitle:AMLocalizedString(@"Log out", nil) actionBlock:^{
        [Flurry logEvent:@"Logout_Confirm"];
        [User logout];
        [GeneralControl transitionToVC:self withToVCStoryboardId:@"Start" withDuration:0.4];
    }];
    [lrf show];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self CardSlide:YES];
}

-(void)CardSlide:(BOOL)left{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(left?0:[self.profileOptions count]-1) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    });
}

-(void)updateUILanguage{
    NSLog(@"**************** card VC update UI language *********************");
    self.profileOptions = [NSArray arrayWithObjects:
                           AMLocalizedString(@"CARD_SEARCH", nil),
                           AMLocalizedString(@"CARD_FEEDBACK",nil),
                           AMLocalizedString(@"CARD_SETTING",nil),
                           AMLocalizedString(@"CARD_LOGOUT", nil), nil];
    [self.bottomCollectionView reloadData];
    
    User *user = [User sharedInstance];
    
    [self.shimmeringView removeFromSuperview];
    
    CGRect titleRect = CGRectMake(LeftMargin, TopMargin, self.view.bounds.size.width, 30);
    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:titleRect];
    self.shimmeringView.shimmering = YES;   //start shimmering
    self.shimmeringView.shimmeringBeginFadeDuration = 0.2;
    self.shimmeringView.shimmeringOpacity = 0.5;
    self.shimmeringView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.shimmeringView];
    _shimmeringView.contentView = self.titleLabel;
    
    
    [self.descriptionLabel removeFromSuperview];
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
    
    
    if(user.Uid == AnonymousUser){
        
        self.titleLabel.text = [NSString stringWithFormat: @"%@",AMLocalizedString(@"ANONYMOUS_HELLO", nil)];
        
        //init view to indicate login
        self.descriptionLabel.text = AMLocalizedString(@"NOT_LOGIN_REGISTERED_TEXT", nil);
        
        [self.registerBtn setTitle:AMLocalizedString(@"LOGIN_REGISTER_BUTTON_TEXT", nil) forState:UIControlStateNormal];
        
        
    }else{
        self.titleLabel.text = [NSString stringWithFormat: @"%@, %@",AMLocalizedString(@"Hello", nil),user.name];
        
        //show
        self.descriptionLabel.text = AMLocalizedString(@"LOGGEDIN_CONTEXT_1", nil);
        self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        
    }
    
    [self.descriptionLabel sizeToFit];
    

    
}

@end
