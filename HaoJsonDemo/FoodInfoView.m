//
//  FoodInfoView.m
//  DetailViewDemo
//
//  Created by Hao Zheng on 6/21/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "FoodInfoView.h"
#import "EDImageCell.h"
#import "JTSImageViewController.h"
#import "JTSImageInfo.h"
#import "UIImageView+M13AsynchronousImageView.h"
#import "CommentCell.h"
#import "LoadControls.h"
#import "ED_Color.h"
#import "User.h"
#import "HATransparentView.h"
#import "DXStarRatingView.h"
#import "LocalizationSystem.h"

static NSString *CellIdentifier = @"Cell";

const CGFloat ScrollViewContentSizeHeight = 1000.f;
const CGFloat kCommentCellHeight = 50.0f;
const CGFloat kCommentCellMaxHeight = 165.f;

const CGFloat CLeftMargin = 15.0f;
const CGFloat TitleTopMargin = 10.0f;
const CGFloat GAP = 6.0f;
const CGFloat MiddleGAP = 10.0f;

const CGFloat TitleLabelHeight = 40.f;
const CGFloat SeparatorViewHeight = 1.f;
const CGFloat BelowShimmmerGap = 10.f;
const CGFloat TranslateLabelHeight = 30.f;
const CGFloat BelowTranslateGap = 10.f;
const CGFloat StarImgViewWidth = 40.f;
const CGFloat StarNumberLabelWidth = 40.f;
const CGFloat DescriptionLabelHeight = 45.f;
const CGFloat BelowDescriptionLabelGap = 1.f;
const CGFloat TagViewHeight = 40.f;
const CGFloat PhotoCollectionViewHeight = 200.f;

static NSString *PlainTextFontName = @"HelveticaNeue-Light";
static NSString *TagTextFontName = @"Heiti TC";
const CGFloat LargeTitleFontSize = 25.f;
const CGFloat LargeTextFontSize = 18.f;
const CGFloat TagFontSize = 18.f;
const CGFloat SmallTitleFontSize = 15.f;
const CGFloat SmallTextFontSize = 20.f;

const CGFloat ViewAlphaRecreaseRate = 450.f;
const NSInteger NumCommentsPerLoad = 5;

const NSUInteger MaxCharNum = 15;
const CGFloat CommentTextViewHeight = 165.f;
const CGFloat CommentViewTopMargin = 26.f;
const CGFloat CloseBtnWidth = 60.f;
const CGFloat CommentTitleHtight = 55.f;
const CGFloat CommentRateViewHeight = 65;
const CGFloat CommentRateViewWidth = 260;

const CGFloat ReadMoreButtonWidth =65;
const CGFloat ReadMoreButtonHeight =25;

@interface FoodInfoView () <UICollectionViewDataSource,UICollectionViewDelegate,TagViewDelegate,UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,EDCommentViewDelegate>



/*current cv must be set up when view appear*/
@property (strong,nonatomic) UIViewController *currentVC;

@property (strong,nonatomic) NSString *imgLoaderName;

//@property (strong,nonatomic) Comment *myComment;

//@property (strong,nonatomic) HATransparentView *commentView;

//@property (strong,nonatomic) NSMutableString *countStr;

//@property (nonatomic) NSUInteger currentStar;

//@property (strong,nonatomic) UILabel *countLabel;

//@property (strong,nonatomic) UIActivityIndicatorView *activityView;

@end

@implementation FoodInfoView


- (id)initWithFrame:(CGRect)frame andVC:(UIViewController *)vc
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentVC = vc;
        self.myFood = nil;
        //self.myComment = nil;
//        self.countStr =[NSMutableString stringWithString:@""];
//        self.commentView = [[HATransparentView alloc] init];
//        self.commentView.delegate = self;
        //self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        //self.activityView.center=self.center;
        //init all UI controls
        [self loadControls];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentVC = nil;
        self.myFood = nil;
        //self.myComment = nil;
//        self.countStr =[NSMutableString stringWithString:@""];
//        self.commentView = [[HATransparentView alloc] init];
//        self.commentView.delegate = self;
        //self.activityView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        //self.activityView.center=self.center;
        //init all UI controls
        [self loadControls];
        
    }
    return self;
}

-(void)setVC:(UIViewController *)vc{
    self.currentVC = nil;
    self.currentVC = vc;
}

-(void)loadControls{
    
    //CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    
    self.scrollview=[[UIScrollView alloc]initWithFrame:self.bounds];
    self.scrollview.delegate = self;
    self.scrollview.showsVerticalScrollIndicator=YES;
    self.scrollview.scrollEnabled=YES;
    self.scrollview.userInteractionEnabled=YES;
    [self addSubview:self.scrollview];
    //should add up all
    //self.scrollview.contentSize = CGSizeMake(width,ScrollViewContentSizeHeight);
    
//    self.shimmeringView = [[FBShimmeringView alloc] init];
//    self.shimmeringView.shimmering = NO;   //start shimmering
//    self.shimmeringView.shimmeringBeginFadeDuration = 0.3;
//    self.shimmeringView.shimmeringOpacity = 0.3;
//    self.shimmeringView.backgroundColor = [UIColor clearColor];
//    [self.scrollview addSubview:self.shimmeringView];
    
    self.titleLabel = [[UILabel alloc] init];//WithFrame:_shimmeringView.frame];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = @"";
    self.titleLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTitleFontSize];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    [self.scrollview addSubview:self.titleLabel];
    //_shimmeringView.contentView = self.titleLabel;
    
    self.separator = [[UIView alloc] init];
    self.separator.backgroundColor = [UIColor blackColor];
    [self.scrollview addSubview:self.separator];
    

    self.translateLabel = [[UILabel alloc] init];
    self.translateLabel.numberOfLines = 0;
    self.translateLabel.lineBreakMode =NSLineBreakByWordWrapping;
    self.translateLabel.text = @"";
    self.translateLabel.font = [UIFont fontWithName:PlainTextFontName size:SmallTextFontSize];
    self.translateLabel.textColor = [UIColor blackColor];
    self.translateLabel.backgroundColor = [UIColor clearColor];
    [self.scrollview addSubview:self.translateLabel];


/*-------------------Following Views Will Be Hidden In Small Layout----------------------------*/
    self.starImgView= [[UIImageView alloc]init];
    self.starImgView.backgroundColor = [UIColor clearColor];
    
    self.starNumberLabel = [[UILabel alloc]init];
    self.starNumberLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTitleFontSize];
    self.starNumberLabel.textColor = [UIColor blackColor];
    self.starNumberLabel.backgroundColor = [UIColor clearColor];
    self.starNumberLabel.textAlignment = NSTextAlignmentCenter;
    self.starNumberLabel.numberOfLines  = 1;
    
    self.starImgView.alpha = 0;
    self.starNumberLabel.alpha = 0;
    
    [self.scrollview addSubview:self.starImgView];
    [self.scrollview addSubview:self.starNumberLabel];
    
    self.descriptionLabel = [[RQShineLabel alloc] init];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.lineBreakMode =NSLineBreakByTruncatingTail;
    self.descriptionLabel.text = @"";
    self.descriptionLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTextFontSize];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    self.descriptionLabel.textColor = [UIColor blackColor];
    
    [self.scrollview addSubview:self.descriptionLabel];
    
    self.readMoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.readMoreBtn setTitle:AMLocalizedString(@"FIV_READ_MORE", nil) forState:UIControlStateNormal];
    self.readMoreBtn.titleLabel.font = [UIFont fontWithName:PlainTextFontName size:SmallTitleFontSize];
    [self.readMoreBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    self.readMoreBtn.backgroundColor = [UIColor clearColor];
    self.readMoreBtn.enabled = YES;
    [self.readMoreBtn addTarget:self action:@selector(readMoreBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    self.readMoreBtn.hidden = YES;
    
    [self.scrollview addSubview:self.readMoreBtn];
    
    self.descrpClearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.descrpClearBtn.backgroundColor = [UIColor clearColor];
    self.descrpClearBtn.enabled = YES;
    [self.descrpClearBtn addTarget:self action:@selector(readMoreBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    self.descrpClearBtn.hidden = YES;
    
    [self.scrollview addSubview:self.descrpClearBtn];
    
    
    _tagview = [[TagView alloc]initWithFrame:CGRectMake(0, BelowDescriptionLabelGap+CGRectGetMaxY(self.descriptionLabel.frame), width, TagViewHeight)];
    _tagview.allowToUseSingleSpace = YES;
    _tagview.delegate = self;
    [_tagview setFont:[UIFont fontWithName:TagTextFontName size:TagFontSize]];
    [_tagview setBackgroundColor:[UIColor clearColor]];
    [self.scrollview addSubview:_tagview];
    
    
    //collectionView + layout
    EDImageFlowLayout *small = [[EDImageFlowLayout alloc]init];
    
    self.photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tagview.frame) + GAP, width, PhotoCollectionViewHeight) collectionViewLayout:small];

    [self.photoCollectionView registerClass:[EDImageCell class] forCellWithReuseIdentifier:CellIdentifier];
    self.photoCollectionView.backgroundColor = [UIColor clearColor];
    self.photoCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self.photoCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.scrollview addSubview:self.photoCollectionView];
    
    //add table view
    //----------------------------comment
    
    _commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, width,10) style:UITableViewStylePlain];
    _commentsTableView.scrollEnabled = NO;
    
    _commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _commentsTableView.separatorColor = [UIColor clearColor];

    //********* finally put in self.view ************
    [self.scrollview addSubview:_commentsTableView];
    
//    //Set scrollview contentSize a little larger so users can scroll to refresh
//    
//    self.scrollview.contentSize = CGSizeMake(width, MAX(CGRectGetMaxY(self.commentsTableView.frame),);
    
    
    //add comment button above scrollview
    _commentBtn = [LoadControls createRoundedButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andLeftBottomElseRightBottom:NO];
    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self hideCommentButton];

    [self addSubview:_commentBtn];
    
    
    //Add loading indicator button
    self.loadingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loadingBtn.frame = self.scrollview.bounds;
    [self.loadingBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.loadingBtn setAlpha:0.5];
    self.loadingBtn.titleLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTextFontSize];
    self.loadingBtn.backgroundColor = [UIColor grayColor];
    [self.loadingBtn addTarget:self action:@selector(loadingBtnPressed) forControlEvents:UIControlEventTouchUpInside];
        NSLog(@"-------------------------FIV LOAD CONTROLLER ---------------------");
    [self hideLoadingBtn];
        NSLog(@"-------------------------FIV LOAD CONTROLLER ---------------------");
    [self addSubview:self.loadingBtn];

    

    
}


/**********************************
 
 scrollview delegate
 
 ************************/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height && !self.myFood.isLoadingComments && !self.photoCollectionView.isTracking) {
        //Request to server
        //Load more comments
        [self refreshComments];

    }
}


/**********************************
 
 collectionView delegate
 
 ************************/
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"~~~~~~%@~~~~~~~~Cell %d~~~~~~~ SHOW ~~~~PHOTO %@ ~~~~~~~~~~~~~~~~~~~~~~",self.myFood.title,(int)indexPath.row,self.myFood.photoNames[indexPath.row]);
    EDImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.activityView.hidden = NO;
    [cell.activityView startAnimating];

    
    //Cancel any other previous downloads for the image view.
    //[cell.imageView cancelLoadingAllImagesAndLoaderName:self.imgLoaderName];

    //Load the new image
    NSLog(@"++++++++++++++++ FIV ++++++++++++++++ IN %@ : LOADER %@ ",self.myFood.title,self.imgLoaderName);
    [cell.imageView loadImageFromURLAtAmazonAsync:[NSURL URLWithString:self.myFood.photoNames[indexPath.row]] withLoaderName:self.imgLoaderName completion:^(BOOL success, M13ImageLoadedLocation location, UIImage *image, NSURL *url, id target) {

        //cell.imageView.image = nil;
        
        cell.activityView.hidden = YES;
        [cell.activityView stopAnimating];
        
        
        //Set the image if loaded
        if (success) {
            
            if(location == M13ImageLoadedLocationCache){
                NSLog(@"it is cache");
                cell.imageView.image = image;
            }else{
                //Hao modified
                [UIView transitionWithView:self
                                  duration:0.6f
                                   options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationCurveEaseInOut
                                animations:^{
                                    cell.imageView.image = image;
                                } completion:nil];
            }
        }else{
            NSLog(@"network failed");
        }
        
    }];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    EDImageCell *cell = (EDImageCell *)[collectionView cellForItemAtIndexPath:indexPath];
    // Create image info
    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
    imageInfo.image = cell.imageView.image;
    imageInfo.referenceRect = cell.imageView.frame;
    imageInfo.referenceView = cell.imageView.superview;
    // Setup view controller
    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                           initWithImageInfo:imageInfo
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundStyle_ScaledDimmedBlurred];
    // Present the view controller.
    [imageViewer showFromViewController:self.currentVC transition:JTSImageViewControllerTransition_FromOriginalPosition];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSLog(@"++++++++ FIV : %@ +++++++++  I get %d photoes",self.myFood.title, (int)self.myFood.photoNames.count);
    return self.myFood.photoNames.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


/**********************************
 
 tableview delegate
 
 ************************/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.myFood.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"---------------------------cell height called!!");
    Comment *comment = (Comment *)[self.myFood.comments objectAtIndex:[indexPath row]];
    NSString *text = [NSString stringWithFormat:@"%@:\n%@",comment.byUser.Uname,comment.text];
    CGRect rect = [text boundingRectWithSize:(CGSize){252, MAXFLOAT}
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont fontWithName:TagTextFontName size:KCommentTextFontSize]}
                                     context:nil];
    CGSize requiredSize = rect.size;

    return kCommentCellHeight + requiredSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Comment *comment = (Comment *)[self.myFood.comments objectAtIndex:[indexPath row]];
    NSString *text = [NSString stringWithFormat:@"%@:\n%@",comment.byUser.Uname,comment.text];
    //NSLog(@"+++++++++++++++++ FIV +++++++++++++++++++ %@ : INSERT COMMENT TBL text = %@",self.myFood.title,text);
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %d", (int)indexPath.row]];
    if (!cell) {
    NSLog(@"+++++++++++++++++ FIV +++++++++++++++++++ %@ : INSERT COMMENT TBL text = %@",self.myFood.title,text);
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Cell %d", (int)indexPath.row]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    
    cell.commentLabel.frame = (CGRect) {.origin = cell.commentLabel.frame.origin, .size = {CGRectGetMaxX(cell.frame) - CGRectGetMaxX(cell.iconView.frame) - kCommentPaddingFromLeft - kCommentPaddingFromRight,[self tableView:tableView heightForRowAtIndexPath:indexPath] - kCommentCellHeight}};
    NSLog(@"+++++++++++ FIV ++++++++++++++ :comment label width %f",cell.commentLabel.frame.size.width);
    cell.timeLabel.frame = (CGRect) {.origin = {CGRectGetMinX(cell.commentLabel.frame), CGRectGetMaxY(cell.commentLabel.frame)}};
    cell.timeLabel.text = @"1d ago";
    [cell.timeLabel sizeToFit];
    
    // Don't judge my magic numbers or my crappy assets!!!
    cell.likeCountImageView.frame = CGRectMake(CGRectGetMaxX(cell.timeLabel.frame) + 7, CGRectGetMinY(cell.timeLabel.frame) + 3, 10, 10);
    cell.likeCountImageView.image = [UIImage imageNamed:@"like_greyIcon.png"];
    cell.likeCountLabel.frame = CGRectMake(CGRectGetMaxX(cell.likeCountImageView.frame) + 3, CGRectGetMinY(cell.timeLabel.frame), 0, CGRectGetHeight(cell.timeLabel.frame));
    
    //set comment text
    cell.commentLabel.text =text;
    /***************** SET TIME OBJECT*******************/


    
    return cell;
}

/*************** MEi **************/
/*                                */
/*           For Animation        */
/*                                */
/*************** MEi **************/

-(void)layoutSubviews{

    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    /*Resize scrollview so that it still can scroll*/
    
    [self.scrollview setFrame:self.bounds];
    
    /*Resize loading button*/
    
    [self.loadingBtn setFrame:self.scrollview.bounds];
    self.loadingBtn.titleLabel.frame = self.loadingBtn.bounds;
    

    
    
    /*Resize views in scroll view*/
    
    CGFloat sizeMultiplier = (height-190)/( CGRectGetHeight([[UIScreen mainScreen] bounds])-190);
    //self.shimmeringView.frame = CGRectMake(CLeftMargin, TitleTopMargin, width-CLeftMargin, ShimmmerViewHeight);
    self.titleLabel.frame = CGRectMake(CLeftMargin, TitleTopMargin, width-CLeftMargin, TitleLabelHeight);
    [self.titleLabel setFont:[UIFont fontWithName:PlainTextFontName size:SmallTitleFontSize + (LargeTitleFontSize-SmallTitleFontSize)*sizeMultiplier]];

    self.separator.frame = CGRectMake(CLeftMargin, CGRectGetMaxY(self.titleLabel.frame), width-2*CLeftMargin, SeparatorViewHeight);
    
    if (self.frame.size.height == CGRectGetHeight([[UIScreen mainScreen] bounds]) && self.myFood.isFoodInfoCompleted){
        self.loadingBtn.hidden = YES;
        
    }else{
        self.loadingBtn.hidden = NO;
    }
    
    self.translateLabel.frame = CGRectMake(CLeftMargin, TitleTopMargin + CGRectGetMaxY(self.titleLabel.frame), width-2*CLeftMargin,  TranslateLabelHeight);
    //[self.translateLabel setFont:[UIFont fontWithName:PlainTextFontName size:SmallTextFontSize + (LargeTitleFontSize-SmallTextFontSize)*sizeMultiplier]];
    
    self.starNumberLabel.frame =CGRectMake(width-CLeftMargin-StarNumberLabelWidth, self.translateLabel.frame.origin.y, StarNumberLabelWidth*(width/[[UIScreen mainScreen] bounds].size.width), CGRectGetHeight(self.translateLabel.frame));
    [self.starNumberLabel setFont:[UIFont fontWithName:PlainTextFontName size:SmallTitleFontSize + (LargeTitleFontSize-SmallTitleFontSize)*sizeMultiplier]];
    
    self.starImgView.frame = CGRectMake(self.starNumberLabel.frame.origin.x-StarImgViewWidth, self.starNumberLabel.frame.origin.y,StarImgViewWidth*(width/[[UIScreen mainScreen] bounds].size.width), CGRectGetHeight(self.translateLabel.frame));
    
    self.descriptionLabel.frame = CGRectMake(CLeftMargin, CGRectGetMaxY(self.translateLabel.frame) + GAP, width - CLeftMargin*2, self.descriptionLabel.frame.size.height);
    
    self.descrpClearBtn.frame = self.descriptionLabel.frame;
    
    //self.readMoreBtn.frame = self.descriptionLabel.frame;
    self.readMoreBtn.frame = CGRectMake(CGRectGetMaxX(self.descriptionLabel.frame)-ReadMoreButtonWidth, CGRectGetMaxY(self.descriptionLabel.frame), ReadMoreButtonWidth, ReadMoreButtonHeight);
    

    self.tagview.frame = CGRectMake(0, CGRectGetMaxY(self.readMoreBtn.frame), width, TagViewHeight);
    
    self.photoCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.tagview.frame) + GAP, width, PhotoCollectionViewHeight);

    
    self.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, width,  CGRectGetHeight(self.commentsTableView.frame));
    
    self.scrollview.contentSize = CGSizeMake(width, MAX(CGRectGetHeight(self.commentsTableView.frame), height)+10);
    /*Change alpha values for 4 special views*/
    
    CGFloat newAlpha= (CGRectGetHeight(self.frame)-ViewAlphaRecreaseRate)/(CGRectGetHeight([[UIScreen mainScreen] bounds])-ViewAlphaRecreaseRate);
    self.descriptionLabel.alpha = newAlpha;
    self.tagview.alpha = newAlpha;
    self.commentsTableView.alpha = newAlpha;
    self.photoCollectionView.alpha = newAlpha;
    self.starImgView.alpha = newAlpha;
    self.starNumberLabel.alpha = newAlpha;
    self.readMoreBtn.alpha = newAlpha;

    NSLog(@"+++ FIV %@ +++  %d LAYOUT SUBVIEW: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.isScrollEnabled,self.scrollview.contentSize.height,self.scrollview.bounds.size.height);
    
}



-(void)setUpForLargeLayout{
    self.userInteractionEnabled = YES;
    self.descriptionLabel.hidden = NO;
    self.tagview.hidden = NO;
    self.photoCollectionView.hidden = NO;
    self.commentsTableView.hidden = NO;
    self.starImgView.hidden = NO;
    self.starNumberLabel.hidden = NO;
    //self.loadingBtn.hidden = NO;
}

-(void)setUpForSmallLayout{
    self.userInteractionEnabled = NO;
    self.descriptionLabel.hidden = YES;
    self.tagview.hidden = YES;
    self.photoCollectionView.hidden = YES;
    self.commentsTableView.hidden = YES;
    self.starImgView.hidden = YES;
    self.starNumberLabel.hidden = YES;
    self.loadingBtn.hidden = YES;
}

/*************** MEi **************/
/*                                */
/*            Rendering           */
/*                                */
/*************** MEi **************/


//Before calling this method, update myFood property
-(void)setFoodInfo{
    self.titleLabel.text = self.myFood.title;
    self.translateLabel.text = self.myFood.transTitle;
    [self changeDescriptionLabelText:self.myFood.food_description];
    if (self.myFood.rate >= 0.f) {
        self.starImgView.contentMode =UIViewContentModeScaleAspectFill;
        self.starImgView.image = [UIImage imageNamed:@"star_on.png"];
        if (self.myFood.rate>0.f) {
            self.starNumberLabel.text = [NSString stringWithFormat:@"%.1f",self.myFood.rate];
        }
        else{
            self.starNumberLabel.text = @"0";
        }
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.starImgView.alpha = 1.0f;
            self.starNumberLabel.alpha = 1.0f;
        } completion:nil];
    }
}

//Load More comments
-(void)refreshComments{
    if (!self.myFood.isLoadingComments) {
        NSLog(@"+++++++++++++ FIV ++++++++++++++++ : refresh comments current count = %d",(int)self.myFood.comments.count);
        [self.myFood fetchLatestCommentsSize:NumCommentsPerLoad andSkip:self.myFood.comments.count completion:^(NSError *err, BOOL success) {
            if(success){
//                NSLog(@"                            Comment text %@",((Comment *)self.myFood.comments[0]).text);
                [self updateCommentTableUI];
            }
        }];
    }
}

//Set up comment table delegate
-(void)configCommentTable{
    _commentsTableView.dataSource = self;
    _commentsTableView.delegate = self;
    [_commentsTableView reloadData];
}


//remember to reload data
-(void)updateCommentTableUI
{
    //NSLog(@"+++FIV+++:update comment table");
    NSInteger newCount = self.myFood.comments.count;
    NSInteger oldCount = [self.commentsTableView numberOfRowsInSection:0];
    
    if (newCount>oldCount){
        NSLog(@"+++ FIV +++ : I refreshed and get %d comments!",(int)(newCount-oldCount));
        
        CGFloat deltaHeight = 0;
        
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:newCount-oldCount];
        
        
        for (int ind = 0; ind < newCount-oldCount; ind++)
        {
            NSIndexPath *newPath =  [NSIndexPath indexPathForRow:oldCount+ind inSection:0];
            [insertIndexPaths addObject:newPath];
            Comment *comment = (Comment *)[self.myFood.comments objectAtIndex:oldCount+ind];
            NSString *text = [NSString stringWithFormat:@"%@:\n%@",comment.byUser.Uname,comment.text];
            CGRect rect = [text boundingRectWithSize:(CGSize){252, MAXFLOAT}
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:TagTextFontName size:KCommentTextFontSize]}
                                             context:nil];
            deltaHeight += (int)(CGRectGetHeight(rect)+kCommentCellHeight);
            
        }
        //NSLog(@"+++ FIV +++ : deltaH = %f",deltaHeight);
        self.commentsTableView.frame =  CGRectMake(self.commentsTableView.frame.origin.x, self.commentsTableView.frame.origin.y, self.commentsTableView.frame.size.width, self.commentsTableView.frame.size.height + deltaHeight);
        //self.scrollview.frame =CGRectMake(self.scrollview.frame.origin.x, self.scrollview.frame.origin.y, self.scrollview.frame.size.width, self.scrollview.frame.size.height + deltaHeight);
        self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,MAX(CGRectGetHeight(self.commentsTableView.frame), self.frame.size.height)+10);
        NSLog(@"+++ FIV %@ +++ UPD CMT UI: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.contentSize.height,self.scrollview.frame.size.height);
        if (!self.commentsTableView.delegate) {
            [self configCommentTable];
        }
        else{
            NSLog(@"++++++++++++ FIV +++++++++++++++ : COMMENTTABLE RELOAD WHEN UPDATING UI");
            [self.commentsTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            //[self.commentsTableView reloadData];
        }
        
        
    }
    
}

//this method got called when cell preparing for reuse
-(void)cleanUpForReuse{
    
    //set the food object in foodInfoView(belonging to collection cell) to nil
    self.myFood = nil;
    //self.myComment = nil;
    //[self.countStr setString:@""];
    self.imgLoaderName = @"";
    
    self.starNumberLabel.text = @"";
    self.starImgView.image = nil;
    self.loadingBtn.hidden = YES;
    [self resetData];
}

-(void)resetData{
    self.myFood.photoNames = nil;//datasource for food photos in bottomCollectionview
    self.photoCollectionView.delegate = nil;
    [self.photoCollectionView reloadData];
    
    self.myFood.comments = nil;//datasource for comment tableview
    self.commentsTableView.delegate = nil;
    [self.commentsTableView reloadData];
    
    [self.tagview clear];
    

}

-(void)fetchFoodInfo{

    [self showLoadingBtnWithLoadingMsg];

    [self.myFood fetchAsyncInfoCompletion:^(NSError *err, BOOL success) {
        //NSLog(@"******************** !!!!!! setting food !!!!!!11 **********************");
        if (success) {
            
            //NSLog(@"******************** !!!!!! setting food !!!!!!22 **********************");
            [self setFoodInfo];
            [self configPhotoAndTag];
            if (self.myFood.comments.count==0) {
                [self refreshComments];
            }
            [self showCommentButton];
            NSLog(@"-------------------------FIV fetchFoodInfo ---------------------");
            [self hideLoadingBtn];
            NSLog(@"-------------------------FIV fetchFoodInfo ---------------------");
            
            
        }
        else{
            
            [self showLoadingBtnWithFailureMsg];
        }
        
    }];
    
}

/******************************************************/
/************  DISPLAY IN COLLECTION VIEW  ************/
/******************************************************/

// Fist time display, set up photoview delegate
-(void)configPhotoAndTag{
    NSLog(@"test```");
    if (self.imgLoaderName && ![self.imgLoaderName isEqualToString:@""]) {
        //NSLog(@"~~~~~~~~~~CONFIG PHOTO FOR %@ ~~~~~~~~~~~~%d",self.myFood.title,(int)self.myFood.photoNames.count);
        
        self.photoCollectionView.dataSource = self;
        self.photoCollectionView.delegate = self;
        
        [self.photoCollectionView reloadData];
        
        [_tagview addTags:self.myFood.tagNames];
        self.descriptionLabel.textColor = [UIColor blackColor];
        
    }
}

//Prepare data for first time display
-(void)prepareForDisplayInCell:(NSInteger)cellNo{
    if (self.myFood) {
        //Assure title and translation are showed;
        [self setFoodInfo];
        self.imgLoaderName =[NSString stringWithFormat:@"%d",(int)cellNo];
        
        //NSLog(@"******************** !!!!!! setting food !!!!!!00 **********************");
        //If food info is not completed, request it
        if (!self.myFood.isLoadingInfo && !self.myFood.isFoodInfoCompleted) {
            [self fetchFoodInfo];


        }
        else if(self.myFood.isFoodInfoCompleted){//Food info is complete, config at once;
            [self configPhotoAndTag];
            [self refreshComments];
            [self showCommentButton];
        }
        
    }
}

/**************************************************/
/************  DISPLAY IN SINGLE VIEW  ************/
/**************************************************/

//Prepare data for first time display IN SINGLE FOOD VIEW
-(void)prepareForDisplay{
    if (self.myFood) {
        //Assure title and translation are showed;
        [self setFoodInfo];
        self.imgLoaderName  = @"Default";
        
        //If food info is not completed, request it
        if (!self.myFood.isLoadingInfo && !self.myFood.isFoodInfoCompleted) {
            [self fetchFoodInfo];

        }
        else if(self.myFood.isFoodInfoCompleted){//Food info is complete, config at once;
            [self configPhotoAndTag];
            [self refreshComments];
            //[self configCommentTable];
            [self showCommentButton];
        }
        
    }
}


-(void)shineDescription{
    if (self.descriptionLabel.text.length>0) {
        [self.descriptionLabel shine];
    }
}


/******************************/
/*                            */
/*      Comment Feature       */
/*                            */
/******************************/

- (void) commentBtnPressed:(id)sender {
    NSLog(@"++++ FIV ++++ : COMMENT BUTTON PRESSED");

    
    EDCommentView *commentView = [[EDCommentView alloc]initWithFrame:self.frame];
    commentView.delegate = self;
    
    Comment* lastcomment = [[User sharedInstance].lastComments objectForKey:[NSString stringWithFormat:@"%d",(int)self.myFood.fid]];
    if (!lastcomment) {
        
        NSLog(@"++++ FIV ++++ : REQUEST COMMENT ");

        [self makeToastActivity];
        [User fetchMyCommentOnFood:self.myFood.fid andCompletion:^(NSError *err, BOOL success) {
            
            [self hideToastActivity];

            [commentView setWithComment:[[User sharedInstance].lastComments objectForKey:[NSString stringWithFormat:@"%d",(int)self.myFood.fid]]];
            
            [commentView setTitleWithFood:self.myFood.title];
            [commentView open];
            
            //[self showCommentView];
            
        }];
    }
    else{   //lastcomment has been loaded
            //open it immediately
        [commentView setWithComment:lastcomment];
        [commentView setTitleWithFood:self.myFood.title];
        [commentView open];
    }

}



-(void)hideCommentButton{
    self.commentBtn.hidden = YES;
    _commentBtn.alpha = .0f;
    //NSLog(@"+++++++++ FIV ++++++++++++ : Hide comment button");
}

-(void)showCommentButton{
    //NSLog(@"+++++++++ FIV ++++++++++++ :UID = %d",(int)[User sharedInstance].Uid);
    if ([User sharedInstance].Uid != AnonymousUser) {
        [UIView animateWithDuration:0.5 animations:^{
            self.commentBtn.hidden = NO;
            self.commentBtn.alpha = 1;
            //NSLog(@"+++++++++ FIV ++++++++++++ : show comment button");
        }];
    }
    
}


#pragma mark - EDCommentView Delegate

-(void)EDCommentView:(HATransparentView *)edCommentView KeyboardReturnedWithStars:(NSUInteger)stars{
    
    //Comment should be sent!
    
    EDCommentView *commentView = (EDCommentView *)edCommentView;
    [commentView makeToastActivity];
    
    Comment *newComment = [[Comment alloc]initWithCommentID:0 andFid:self.myFood.fid andRate:stars andComment:commentView.textView.text];
    
    [[User sharedInstance].lastComments setObject:newComment forKey:[NSString stringWithFormat:@"%d",(int)self.myFood.fid]];
    
    NSLog(@"+++++++++++++++ FIV +++++WILL SEND COMMENT+++++++++++++++++++");
    [User createComment:newComment andCompletion:^(NSError *err, BOOL success, CGFloat newRate) {
        if (success)
        {
            NSLog(@"+++++++++++++++ FIV +++++SEND COMMENT SUCCEED+++++++++++++++++++");
            [commentView hideToastActivity];
            [commentView close];
            
            //Update rate labels;
            if (newRate>0.f) {
                self.starNumberLabel.text = [NSString stringWithFormat:@"%.1f",newRate];
            }
            else{
                self.starNumberLabel.text = @"0";
            }
            
            [self makeToast:AMLocalizedString(@"SUCCESS_COMMENT", nil) duration:0.8 position:@"bottom"];
            
            //Remove old comment data
            [self.myFood.comments removeAllObjects];
            [self.commentsTableView reloadData];
            
            //update related UI
            self.commentsTableView.frame = CGRectMake(self.commentsTableView.frame.origin.x, self.commentsTableView.frame.origin.y,self.commentsTableView.frame.size.width, 10);
            [self.scrollview setContentOffset:CGPointZero animated:YES];
            self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,CGRectGetHeight(self.commentsTableView.frame)+10);
            
            //refresh comments
            [self refreshComments];
        }
        else{
            [commentView hideToastActivity];
            [commentView makeToast:AMLocalizedString(@"FAIL_COMMENT", nil) duration:0.8 position:@"center"];
        }
    }];

    
}

/************************************/
/*****     Loading Indicator     ****/
/************************************/

-(void)showLoadingBtnWithLoadingMsg{
        self.loadingBtn.enabled = NO;
    NSLog(@"+++++++++++ FIV ++++++++++++ %@ : showloading button!!!!!!!!!!!!!!",self.myFood.title);
    [self.loadingBtn setTitle:AMLocalizedString(@"FIV_LOADING_MSG", nil) forState:UIControlStateNormal];

    self.loadingBtn.alpha = 0.5;
}

-(void)hideLoadingBtn{
    NSLog(@"+++++++++++ FIV ++++++++++++ %@ : hideloading button!!!!!!!!!!!!!!",self.myFood.title);
        self.loadingBtn.alpha = 0.f;
        self.loadingBtn.hidden  = YES;
        self.loadingBtn.enabled = NO;
        [self.loadingBtn setTitle:@"" forState:UIControlStateNormal];

    
}

-(void)showLoadingBtnWithFailureMsg{
        NSLog(@"+++++++++++ FIV ++++++++++++ %@ : show failure button!!!!!!!!!!!!!!",self.myFood.title);
        self.loadingBtn.enabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            [self.loadingBtn setTitle:AMLocalizedString(@"FIV_LOADING_FAIL", nil) forState:UIControlStateNormal];
             self.loadingBtn.alpha = 0.5;
        } ];
    
     
}
-(void)loadingBtnPressed{
    NSLog(@"Loading btn pressed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

    [self fetchFoodInfo];

}

/************************************/
/*****     Tap to Read More     ****/
/************************************/

//If you want to change description label text, use this method instead
//It will change the layout accordingly
-(void) changeDescriptionLabelText:(NSString *)newText{
    CGFloat width = [[UIScreen mainScreen]bounds].size.width;
    CGRect expectedRect = [newText boundingRectWithSize:CGSizeMake(width-2*CLeftMargin, MAXFLOAT)
                       options:NSStringDrawingUsesLineFragmentOrigin
                    attributes:@{NSFontAttributeName:[UIFont fontWithName:PlainTextFontName size:LargeTextFontSize]}
                       context:nil];
    
    //Text too long, show read more button
    if (expectedRect.size.height > DescriptionLabelHeight)
    {
        self.descrpClearBtn.hidden = NO;
        self.readMoreBtn.hidden = NO;
        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.descriptionLabel.frame.origin.y, self.descriptionLabel.frame.size.width, DescriptionLabelHeight);

    }
    else{
         //Text can be showed in the constraint rect
         //Change height accordingly
        self.descrpClearBtn.hidden = YES;
        self.readMoreBtn.hidden = YES;
        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.descriptionLabel.frame.origin.y, self.descriptionLabel.frame.size.width, expectedRect.size.height);
    
    }
    
    self.descriptionLabel.text = newText;
    
    //update other ui blow description label
    [self layoutSubviews];

    //update contensize
    self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,MAX(CGRectGetHeight(self.commentsTableView.frame), self.frame.size.height)+10);
}

-(void)readMoreBtnPressed{
    NSLog(@"ReadMoreButton Pressed  label TEXT = %@",self.descriptionLabel.text);
    CGFloat width = [[UIScreen mainScreen]bounds].size.width;
    CGRect expectedRect = [self.descriptionLabel.text boundingRectWithSize:CGSizeMake(width-2*CLeftMargin, MAXFLOAT)
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:@{NSFontAttributeName:[UIFont fontWithName:PlainTextFontName size:LargeTextFontSize]}
                                                context:nil];
    if ([self.readMoreBtn.titleLabel.text isEqualToString:AMLocalizedString(@"FIV_READ_MORE", nil)])
    {
        [self.readMoreBtn setTitle:AMLocalizedString(@"FIV_READ_LESS", nil) forState:UIControlStateNormal];

        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.descriptionLabel.frame.origin.y, self.descriptionLabel.frame.size.width,expectedRect.size.height);


    }else
    {
        [self.readMoreBtn setTitle:AMLocalizedString(@"FIV_READ_MORE", nil) forState:UIControlStateNormal];
  
        self.descriptionLabel.frame = CGRectMake(self.descriptionLabel.frame.origin.x, self.descriptionLabel.frame.origin.y, self.descriptionLabel.frame.size.width,DescriptionLabelHeight);


    
    }
    [self layoutSubviews];
    //self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,MAX(CGRectGetHeight(self.commentsTableView.frame), self.frame.size.height)+10);

}
@end
