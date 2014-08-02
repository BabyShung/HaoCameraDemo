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
#import "HATransparentView.h"
#import "DXStarRatingView.h"

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
const CGFloat LargeTranslateLabelHeight = 30.f;
const CGFloat SmallTranslateLabelHeight = 100.f;
const CGFloat BelowTranslateGap = 10.f;
const CGFloat StarImgViewWidth = 40.f;
const CGFloat StarNumberLabelWidth = 40.f;
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

@interface FoodInfoView () <UICollectionViewDataSource,UICollectionViewDelegate,TagViewDelegate,UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate,EDCommentViewDelegate,LoadingIndicatorViewDelegate,DescriptionViewDelegate>

/*current cv must be set up when view appear*/
@property (strong,nonatomic) UIViewController *currentVC;

@property (strong,nonatomic) NSString *imgLoaderName;

@property (strong,nonatomic) UILabel *noCommentLabel;

@end

@implementation FoodInfoView

- (id)initWithFrame:(CGRect)frame andVC:(UIViewController *)vc{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentVC = vc;
        self.myFood = nil;
        
        [self loadControls];
        
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentVC = nil;
        self.myFood = nil;

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


/*--------------Following Views Will Be Hidden In Small Layout------------------*/
    
    //Stars(Rating) view
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
    
    //Description View
    self.descripView = [[DescriptionView alloc]init];
    self.descripView.boundedContentWidth = [[UIScreen mainScreen]bounds].size.width-2*CLeftMargin;
    self.descripView.delegate =self;
    [self.scrollview addSubview:self.descripView];
    
    //Tag View
    _tagview = [[TagView alloc]initWithFrame:CGRectMake(0, BelowDescriptionLabelGap+CGRectGetMaxY(self.descripView.frame), width, TagViewHeight)];
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
    
    _commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, width,kCommentCellHeight) style:UITableViewStylePlain];
    _commentsTableView.scrollEnabled = NO;
    //_commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _commentsTableView.separatorColor = [UIColor clearColor];
    
    [self.scrollview addSubview:_commentsTableView];
    
    _noCommentLabel = [[UILabel alloc]initWithFrame:_commentsTableView.frame];
    _noCommentLabel.numberOfLines = 2;
    _noCommentLabel.textAlignment = NSTextAlignmentCenter;
    _noCommentLabel.font = [UIFont fontWithName:PlainTextFontName size:15];
    _noCommentLabel.textColor = [UIColor lightGrayColor];
    _noCommentLabel.hidden = YES;
    
    [self.scrollview addSubview:_noCommentLabel];
 
    //add comment button above scrollview
    _commentBtn = [LoadControls createRoundedButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andLeftBottomElseRightBottom:NO];
    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self hideCommentButton];

    [self addSubview:_commentBtn];
    
}

/**********************************
 
 scrollview delegate
 
 ************************/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height && !self.myFood.isLoadingComments && !self.photoCollectionView.isTracking) {
        //Request to server
        //Load more comments
        [self refreshComments];

    }
}


/**********************************
 
 collectionView delegate
 
 ************************/
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    //NSLog(@"~~~~~~%@~~~~~~~~Cell %d~~~~~~~ SHOW ~~~~PHOTO %@ ~~~~~~~~~~~~~~~~~~~~~~",self.myFood.title,(int)indexPath.row,self.myFood.photoNames[indexPath.row]);
    EDImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.activityView.hidden = NO;
    [cell.activityView startAnimating];

    //Cancel any other previous downloads for the image view.
    //[cell.imageView cancelLoadingAllImagesAndLoaderName:self.imgLoaderName];

    //Load the new image
    NSLog(@"++++++++++++++++ FIV ++++++++++++++++ IN %@ : LOADER %@ ",self.myFood.title,self.imgLoaderName);
    [cell.imageView loadImageFromURLAtAmazonAsync:[NSURL URLWithString:self.myFood.photoNames[indexPath.row]] withLoaderName:self.imgLoaderName completion:^(BOOL success, M13ImageLoadedLocation location, UIImage *image, NSURL *url, id target) {
        
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

        cell.commentLabel.frame = (CGRect) {.origin = cell.commentLabel.frame.origin, .size = {CGRectGetMaxX(cell.frame) - CGRectGetMaxX(cell.iconView.frame) - kCommentPaddingFromLeft - kCommentPaddingFromRight,[self tableView:tableView heightForRowAtIndexPath:indexPath] - kCommentCellHeight}};
        cell.timeLabel.frame = (CGRect) {.origin = {CGRectGetMinX(cell.commentLabel.frame), CGRectGetMaxY(cell.commentLabel.frame)+GAP}};
    }
    


    cell.commentLabel.text =text;
    

    cell.timeLabel.text = [comment.createdTime stringFormatedForComment];
   [cell.timeLabel sizeToFit];

    
//    // Don't judge my magic numbers or my crappy assets!!!
//    cell.likeCountImageView.frame = CGRectMake(CGRectGetMaxX(cell.timeLabel.frame) + 7, CGRectGetMinY(cell.timeLabel.frame) + 3, 10, 10);
//    cell.likeCountImageView.image = [UIImage imageNamed:@"like_greyIcon.png"];
//    cell.likeCountLabel.frame = CGRectMake(CGRectGetMaxX(cell.likeCountImageView.frame) + 3, CGRectGetMinY(cell.timeLabel.frame), 0, CGRectGetHeight(cell.timeLabel.frame));
    



    
    return cell;
}

/*************** MEi **************/
/*                                */
/*           For Animation        */
/*                                */
/*************** MEi **************/

-(void)layoutSubviews{
    [super layoutSubviews];

    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    
    [self.scrollview setFrame:self.bounds];
    
    /*Resize loading button*/
    
    [self.loadingIndicator setFrame:self.bounds];
    
    
    /*Resize views in scroll view*/
    
    CGFloat sizeMultiplier = (height-(iPhone5? 185:155))/( CGRectGetHeight([[UIScreen mainScreen] bounds])-(iPhone5? 185:155));
    //self.shimmeringView.frame = CGRectMake(CLeftMargin, TitleTopMargin, width-CLeftMargin, ShimmmerViewHeight);
    self.titleLabel.frame = CGRectMake(CLeftMargin, TitleTopMargin, width-CLeftMargin, TitleLabelHeight);
    [self.titleLabel setFont:[UIFont fontWithName:PlainTextFontName size:SmallTitleFontSize + (LargeTitleFontSize-SmallTitleFontSize)*sizeMultiplier]];

    self.separator.frame = CGRectMake(CLeftMargin, CGRectGetMaxY(self.titleLabel.frame), width-2*CLeftMargin, SeparatorViewHeight);

    
    self.translateLabel.frame = CGRectMake(CLeftMargin, TitleTopMargin + CGRectGetMaxY(self.titleLabel.frame), width-2*CLeftMargin,  SmallTranslateLabelHeight - (SmallTranslateLabelHeight - LargeTranslateLabelHeight)*sizeMultiplier);//TranslateLabelHeight);
    [self.translateLabel sizeToFit];
    
    self.starNumberLabel.frame =CGRectMake(width-CLeftMargin-StarNumberLabelWidth, self.translateLabel.frame.origin.y, StarNumberLabelWidth*(width/[[UIScreen mainScreen] bounds].size.width), CGRectGetHeight(self.translateLabel.frame));
    [self.starNumberLabel setFont:[UIFont fontWithName:PlainTextFontName size:SmallTitleFontSize + (LargeTitleFontSize-SmallTitleFontSize)*sizeMultiplier]];
    
    self.starImgView.frame = CGRectMake(self.starNumberLabel.frame.origin.x-StarImgViewWidth, self.starNumberLabel.frame.origin.y,StarImgViewWidth*(width/[[UIScreen mainScreen] bounds].size.width), CGRectGetHeight(self.translateLabel.frame));
    self.descripView.frame = CGRectMake(CLeftMargin, CGRectGetMaxY(self.translateLabel.frame) + GAP, width - CLeftMargin*2, self.descripView.frame.size.height);
    

    self.tagview.frame = CGRectMake(0, CGRectGetMaxY(self.descripView.frame), width, TagViewHeight);
    
    self.photoCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.tagview.frame) + GAP, width, PhotoCollectionViewHeight);


    self.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, width,  CGRectGetHeight(self.commentsTableView.frame));
    self.noCommentLabel.frame =CGRectMake(0, self.commentsTableView.frame.origin.y,width,  CGRectGetHeight(self.noCommentLabel.frame));
    
    self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,MAX(CGRectGetMaxY(self.commentsTableView.frame), height)+10);
    
    /*Change alpha values for 4 special views*/
    
    CGFloat newAlpha= (CGRectGetHeight(self.frame)-ViewAlphaRecreaseRate)/(CGRectGetHeight([[UIScreen mainScreen] bounds])-ViewAlphaRecreaseRate);
    self.descripView.alpha = newAlpha;
    self.tagview.alpha = newAlpha;
    self.commentsTableView.alpha = newAlpha;
    self.photoCollectionView.alpha = newAlpha;
    self.starImgView.alpha = newAlpha;
    self.starNumberLabel.alpha = newAlpha;
    //self.readMoreBtn.alpha = newAlpha;
    self.noCommentLabel.alpha = newAlpha;

    NSLog(@"+++ FIV %@ +++  %d LAYOUT SUBVIEW: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.isScrollEnabled,self.scrollview.contentSize.height,self.scrollview.bounds.size.height);
    
}



-(void)setUpForLargeLayout{
    self.userInteractionEnabled = YES;
    self.descripView.hidden = NO;
    self.tagview.hidden = NO;
    self.photoCollectionView.hidden = NO;
    self.commentsTableView.hidden = NO;
    self.starImgView.hidden = NO;
    self.starNumberLabel.hidden = NO;
    //self.loadingBtn.hidden = NO;
}

-(void)setUpForSmallLayout{
    self.userInteractionEnabled = NO;
    self.descripView.hidden = YES;
    self.tagview.hidden = YES;
    self.photoCollectionView.hidden = YES;
    self.commentsTableView.hidden = YES;
    self.starImgView.hidden = YES;
    self.starNumberLabel.hidden = YES;
    //self.loadingBtn.hidden = YES;
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
    self.descripView.contentText = self.myFood.food_description;
    //[self changeDescriptionLabelText:self.myFood.food_description];
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
        if (self.myFood.comments.count == 0){
            _noCommentLabel.text= AMLocalizedString(@"COMMENT_LOADING_MSG", nil);
            _noCommentLabel.hidden = NO;
        }
        [self.myFood fetchLatestCommentsSize:NumCommentsPerLoad andSkip:self.myFood.comments.count completion:^(NSError *err, BOOL success) {
            if(success){
                if (self.myFood.comments.count == 0) {
                    if ([User sharedInstance].Uid == AnonymousUser) {
                        _noCommentLabel.text = [NSString stringWithFormat:AMLocalizedString(@"FIV_NO_COMMENT", nil),self.myFood.title];
                    }
                    else{
                        _noCommentLabel.text = [NSString stringWithFormat:AMLocalizedString(@"FIV_NO_COMMENT_LOGINUSR", nil),[User sharedInstance].name,self.myFood.title];
                    }
                    _noCommentLabel.hidden = NO;
                }else {
                    _noCommentLabel.text = @"";
                    _noCommentLabel.hidden = YES;
                }
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

        NSLog(@"+++ FIV %@ +++ UPD CMT UI: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.contentSize.height,self.scrollview.frame.size.height);
        if (!self.commentsTableView.delegate) {
            [self configCommentTable];
        }
        else{
            NSLog(@"++++++++++++ FIV +++++++++++++++ : COMMENTTABLE RELOAD WHEN UPDATING UI");
            [self.commentsTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
            
        }
        
        self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,MAX( CGRectGetMaxY(self.commentsTableView.frame),self.scrollview.frame.size.height)+10);
        
        
    }
    
}

//this method got called when cell preparing for reuse
-(void)cleanUpForReuse{
    
    //set the food object in foodInfoView(belonging to collection cell) to nil
    self.myFood = nil;
    self.imgLoaderName = @"";
    
    self.starNumberLabel.text = @"";
    self.starImgView.image = nil;
    
    [self.descripView resetData];
    self.noCommentLabel.text = @"";
    self.noCommentLabel.hidden = YES;
    
    self.myFood.photoNames = nil;//datasource for food photos in bottomCollectionview
    self.photoCollectionView.delegate = nil;
    [self.photoCollectionView reloadData];
    
    self.myFood.comments = nil;//datasource for comment tableview
    self.commentsTableView.delegate = nil;
    [self.commentsTableView reloadData];
    self.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, CGRectGetWidth(self.commentsTableView.frame),  kCommentCellHeight);
    
    [self.tagview clear];
}

//-(void)resetData{
//    self.myFood.photoNames = nil;//datasource for food photos in bottomCollectionview
//    self.photoCollectionView.delegate = nil;
//    [self.photoCollectionView reloadData];
//    
//    self.myFood.comments = nil;//datasource for comment tableview
//    self.commentsTableView.delegate = nil;
//    [self.commentsTableView reloadData];
//    self.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, CGRectGetWidth(self.commentsTableView.frame),  kCommentCellHeight);
//
//    [self.tagview clear];
//    
//
//}

-(void)fetchFoodInfo{
    
    if (!self.loadingIndicator) {
        self.loadingIndicator = [[LoadingIndicatorView alloc] initWithFrame:self.frame];
        self.loadingIndicator.delegate = self;
        [self addSubview:self.loadingIndicator];
    }


    [_loadingIndicator showLoadingMsg];

    [self.myFood fetchAsyncInfoCompletion:^(NSError *err, BOOL success) {
        //NSLog(@"******************** !!!!!! setting food !!!!!!11 **********************");
        if (success) {
            
            [self.loadingIndicator removeFromSuperview];

            [self setFoodInfo];
            [self configPhotoAndTag];
            if (self.myFood.comments.count==0) {
                [self refreshComments];
            }
            [self showCommentButton];

            
            
        }
        else{
            [_loadingIndicator showFailureMsg];
            //[self showLoadingBtnWithFailureMsg];
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
        [self.descripView config];
        //self.descriptionLabel.textColor = [UIColor blackColor];
        
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
    [self.descripView shine];
//    if (self.descriptionLabel.text.length>0) {
//        [self.descriptionLabel shine];
//    }
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
            
            [self makeToast:AMLocalizedString(@"SUCCESS_COMMENT", nil) duration:0.8 position:@"bottom"];
            
            //Remove old comment data
            [self.myFood.comments removeAllObjects];
            [self.commentsTableView reloadData];
            
            //update related UI
            self.commentsTableView.frame = CGRectMake(self.commentsTableView.frame.origin.x, self.commentsTableView.frame.origin.y,self.commentsTableView.frame.size.width, kCommentCellHeight);
            [self.scrollview setContentOffset:CGPointZero animated:NO];
            self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,MAX( CGRectGetMaxY(self.commentsTableView.frame),self.scrollview.frame.size.height)+10);
            
            //refresh comments
            [self refreshComments];
        }
        else{
            [commentView hideToastActivity];
            if (!err) {
                [commentView makeToast:AMLocalizedString(@"FAIL_COMMENT", nil) duration:0.8 position:@"center"];
            }
            else{
                [commentView makeToast:AMLocalizedString(@"FAIL_COMMENT_EMOJI", nil) duration:0.8 position:@"center"];
            }
            
        }
    }];

    
}

/************************************/
/*****     Loading Indicator     ****/
/************************************/

#pragma mark - LoadingIndicatorView Delegate

-(void) LoadingIndicatorFireReLoad
{
    //    NSLog(@"Loading btn pressed!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    [self fetchFoodInfo];
}

/************************************/
/*****     Tap to Read More     ****/
/************************************/

#pragma mark - DescriptionView Delegate
-(void)DesciprionViewReadMoreFired{
    [self layoutSubviews];

}

-(void)DesciprionViewTextDidChanged{
    [self layoutSubviews];
}

@end
