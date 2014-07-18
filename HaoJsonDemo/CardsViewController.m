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
#import "LoginViewController.h"
#import "IPDashedLineView.h"
#import "Flurry.h"
#import "LocalizationSystem.h"
#import "HATransparentView.h"
#import "GeneralControl.h"

#define CROPVIEW_HEIGHT iPhone5?360:300

const NSString *collectionCellIdentity = @"Cell";
const CGFloat LeftMargin = 15.0f;
const CGFloat LeftContextMargin = 40.f;
const CGFloat TopContextMargin = 100.0f;
const CGFloat TopMargin = 25.0f;
static NSArray *colors;

@interface CardsViewController () <UICollectionViewDataSource,
UICollectionViewDelegate,HATransparentViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) MKTransitionCoordinator *menuInteractor;

@property (nonatomic, weak) IBOutlet UICollectionView *bottomCollectionView;

@property (strong,nonatomic) NSArray *languages;

@property (strong,nonatomic) NSArray *settings;
@property (strong,nonatomic) NSArray *settingsImages;

@property (strong,nonatomic) UILabel *titleLabel;
@property (strong,nonatomic) FBShimmeringView *shimmeringView;
@property (strong, nonatomic) RQShineLabel *descriptionLabel;

@property (strong, nonatomic) UIButton * previousPageBtn;

@property (strong,nonatomic) NSString *tempFeedbackText;

@property (strong, nonatomic) UIView * separatorLine;

@property (strong, nonatomic) HATransparentView *transparentView;
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
    
    colors = @[[ED_Color cardLightBlue],[ED_Color cardLightGreen],[ED_Color cardMediumBlue],[UIColor whiteColor],[ED_Color cardLightYellow],[ED_Color cardPink]];
    self.settings = [NSArray arrayWithObjects:
                     AMLocalizedString(@"CARD_SEARCH", nil),
                     AMLocalizedString(@"CARD_FEEDBACK",nil),
                     AMLocalizedString(@"LANGUAGUE_SETTING",nil),
                     AMLocalizedString(@"TUTORIAL_STRING", nil),
                     AMLocalizedString(@"CARD_ABOUT", nil),
                     AMLocalizedString(@"CARD_LOGOUT", nil), nil];
    self.settingsImages = [NSArray arrayWithObjects:
                           [UIImage imageNamed:@"ED_search.png"],
                           [UIImage imageNamed:@"ED_feedback.png"],
                           [UIImage imageNamed:@"ED_switchLanguage.png"],
                           [UIImage imageNamed:@"ED_about.png"],
                           [UIImage imageNamed:@"ED_aboutUs.png"],
                           [UIImage imageNamed:@"ED_logout.png"], nil];
    
    self.languages = [NSArray arrayWithObjects:
                      @"中文",
                      @"English",
                      nil];
}

-(void)checkUserStatusAtProfileBoard{
    User *user = [User sharedInstance];
    
    
    if(user.Uid == AnonymousUser){
        
        self.titleLabel.text = [NSString stringWithFormat: @"%@",AMLocalizedString(@"ANONYMOUS_HELLO", nil)];
        
        //init view to indicate login
        self.descriptionLabel.text = AMLocalizedString(@"NOT_LOGIN_REGISTERED_TEXT", nil);
        
        UIButton *registerBtn = [[UIButton alloc]initWithFrame:CGRectMake(LeftContextMargin, 190, 240, 50)];
        [registerBtn addTarget:self action:@selector(PressedRegisterButton:) forControlEvents:UIControlEventTouchUpInside];
        [registerBtn setTitle:AMLocalizedString(@"LOGIN_REGISTER_BUTTON_TEXT", nil) forState:UIControlStateNormal];
        [registerBtn successStyle];
        [self.view addSubview:registerBtn];
        
        
        
    }else{
        self.titleLabel.text = [NSString stringWithFormat: @"%@, %@",AMLocalizedString(@"Hello", nil),user.name];
        
        //show
        self.descriptionLabel.text = AMLocalizedString(@"LOGGEDIN_CONTEXT_1", nil);
        self.descriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        
    }
    
    [self.descriptionLabel sizeToFit];
}


- (void) previousPagePressed:(id)sender {
    [self.settingDelegate slideToPreviousPage];
}

-(void)PressedRegisterButton:(id)stuff{
    
    [User logout];
    
    [GeneralControl transitionToVC:self withToVCStoryboardId:@"Start" withDuration:0.4];
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    if(self.shimmeringView.shimmering){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.shimmeringView.shimmering = NO;
        });
        [self.descriptionLabel shine];
    }
    
    [GeneralControl setPageViewControllerScrollEnabled:YES];
    
}

-(void)loadControls{
    
    //separator line
    IPDashedLineView *appearance = [IPDashedLineView appearance];
    [appearance setLineColor:[UIColor whiteColor]];
    [appearance setLengthPattern:@[@12, @4]];
    IPDashedLineView *dash0 = [[IPDashedLineView alloc] initWithFrame:CGRectMake(10, CROPVIEW_HEIGHT, 300, 1)];
    [self.view addSubview:dash0];
    
    
    _previousPageBtn = [LoadControls createRoundedButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andLeftBottomElseRightBottom:YES];
    [_previousPageBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_previousPageBtn];
    
    
    self.menuInteractor = [[MKTransitionCoordinator alloc] initWithParentViewController:self];
    self.menuInteractor.disableLeftEdgePan = NO;
    self.menuInteractor.disableRightEdgePan = YES;
    
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
    
    
    //[GeneralControl setPageViewControllerScrollEnabled:NO];
    
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
        
        _transparentView = [[HATransparentView alloc] init];
        _transparentView.delegate = self;
        [_transparentView open];
        
        // Add a tableView
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 84, _transparentView.frame.size.width, _transparentView.frame.size.height - 84)];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [_transparentView addSubview:tableView];

        
    }else if (index == 3){
        
    }else if (index == 4){
        
        [Flurry logEvent:@"Index_2_About"];
        
        [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"AboutUs"] animated:YES];
    }
    else if (index == 5){
        
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

//-(void)viewDidDisappear:(BOOL)animated{
//    
//}

-(void)viewWillDisappear:(BOOL)animated{
    [self CardSlide:YES];
}

-(void)CardSlide:(BOOL)left{
    [self.bottomCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:(left?0:[self.settings count]-1) inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - TableView Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.languages.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    static NSString *cellId = @"cellId";
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    UIImageView *check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    
    cell.textLabel.text = self.languages[indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:143/255.0 blue:213/255.0 alpha:1.0];
    cell.accessoryView = (_selected == indexPath.row) ? check : nil;
    
    return cell;
}


#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selected inSection:0]];
    lastCell.accessoryView = nil;
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *check = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"check"]];
    cell.accessoryView = check;
    _selected = indexPath.row;
    
    // Remove
    //[_transparentView close];
}

#pragma mark - HATransparentViewDelegate

- (void)HATransparentViewDidClosed
{
    NSLog(@"Did close");
}
@end
