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
#import "Comment.h"
#import "LoadControls.h"
#import "ED_Color.h"
#import "User.h"

static NSString *CellIdentifier = @"Cell";

const CGFloat ScrollViewContentSizeHeight = 1000.f;
const CGFloat kCommentCellHeight = 50.0f;
const CGFloat kCommentCellMaxHeight = 100.f;

const CGFloat CLeftMargin = 15.0f;
const CGFloat TitleTopMargin = 10.0f;
const CGFloat GAP = 6.0f;
const CGFloat MiddleGAP = 20.0f;

const CGFloat ShimmmerViewHeight = 40.f;
const CGFloat SeparatorViewHeight = 1.f;
const CGFloat BelowShimmmerGap = 10.f;
const CGFloat TranslateLabelHeight = 70.f;
const CGFloat BelowTranslateGap = 20.f;
const CGFloat DescriptionLabelHeight = 40.f;
const CGFloat BelowDescriptionLabelGap = 20.f;
const CGFloat TagViewHeight = 40.f;
const CGFloat PhotoCollectionViewHeight = 268.f;

static NSString *PlainTextFontName = @"HelveticaNeue-Light";
static NSString *TagTextFontName = @"Heiti TC";
const CGFloat LargeTitleFontSize = 25.f;
const CGFloat LargeTextFontSize = 20.f;
const CGFloat TagFontSize = 18.f;
const CGFloat SmallTitleFontSize = 15.f;
const CGFloat SmallTextFontSize = 10.f;

const CGFloat ViewAlphaRecreaseRate = 450.f;
const  NSInteger NumCommentsPerLoad = 5;

@interface FoodInfoView () <UICollectionViewDataSource,UICollectionViewDelegate,TagViewDelegate,UITableViewDataSource, UITableViewDelegate,UIScrollViewDelegate>



/*current cv must be set up when view appear*/
@property (strong,nonatomic) UIViewController *currentVC;

@property (strong,nonatomic) NSString *imgLoaderName;
@end

@implementation FoodInfoView


- (id)initWithFrame:(CGRect)frame andVC:(UIViewController *)vc
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentVC = vc;
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
    
    self.shimmeringView = [[FBShimmeringView alloc] init];
    self.shimmeringView.shimmering = NO;   //start shimmering
    self.shimmeringView.shimmeringBeginFadeDuration = 0.3;
    self.shimmeringView.shimmeringOpacity = 0.3;
    self.shimmeringView.backgroundColor = [UIColor clearColor];
    [self.scrollview addSubview:self.shimmeringView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:_shimmeringView.frame];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.text = @"";
    self.titleLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTitleFontSize];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    _shimmeringView.contentView = self.titleLabel;
    
    self.separator = [[UIView alloc] init];
    self.separator.backgroundColor = [UIColor blackColor];
    [self.scrollview addSubview:self.separator];
    

    self.translateLabel = [[UILabel alloc] init];
    self.translateLabel.numberOfLines = 0;
    self.translateLabel.text = @"";
    self.translateLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTextFontSize];
    self.translateLabel.textColor = [UIColor blackColor];
    self.translateLabel.backgroundColor = [UIColor clearColor];
    [self.scrollview addSubview:self.translateLabel];
    
/*-------------------Following Views Will Be Hidden In Small Layout----------------------------*/
    
    self.descriptionLabel = [[RQShineLabel alloc] init];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text = @"";
    self.descriptionLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTextFontSize];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];

    self.descriptionLabel.textColor = [UIColor blackColor];
    
    [self.scrollview addSubview:self.descriptionLabel];
    
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
    self.scrollview.contentSize = CGSizeMake(width, CGRectGetMaxY(self.commentsTableView.frame)+10);
    
    //add comment button above scrollview
    _commentBtn = [LoadControls createRoundedButton_Image:@"ED_feedback_right.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(7, 7, 7, 7) andCenter:CGPointMake(320-10-20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
    [_commentBtn addTarget:self action:@selector(commentBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self hideCommentButton];
    [self addSubview:_commentBtn];

    
}


/**********************************
 
 scrollview delegate
 
 ************************/

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height && !self.myFood.isLoadingComments) {
        //Request to server
        //Load more comments
        [self.myFood fetchOldestCommentsSize:NumCommentsPerLoad andSkip:self.myFood.comments.count completion:^(NSError *err, BOOL success) {
            if(success){

                [self updateCommentTableUI];
                [self.commentsTableView reloadData];
            }
        }];
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
    [cell.imageView cancelLoadingAllImagesAndLoaderName:self.imgLoaderName];

    //Load the new image
    [cell.imageView loadImageFromURLAtAmazonAsync:[NSURL URLWithString:self.myFood.photoNames[indexPath.row]] withLoaderName:self.imgLoaderName completion:^(BOOL success, M13ImageLoadedLocation location, UIImage *image, NSURL *url, id target) {

        cell.activityView.hidden = YES;
        [cell.activityView stopAnimating];
        
        //cell.imageView.image = image;
        
        
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
    NSLog(@"++++++++ FIV : %@ +++++++++  I get %d photoes",self.myFood.title, (int)self.myFood.photoNames.count);
    return self.myFood.photoNames.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


/**********************************
 
 tableview delegate
 
 ************************/
#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.myFood.comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Comment *comment = (Comment *)[self.myFood.comments objectAtIndex:[indexPath row]];
    NSString *text = [NSString stringWithFormat:@"%@:\n%@",comment.byUser.Uname,comment.text];
    CGRect rect = [text boundingRectWithSize:(CGSize){225, kCommentCellMaxHeight}
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]}
                                     context:nil];
    CGSize requiredSize = rect.size;

    return kCommentCellHeight + requiredSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Comment *comment = (Comment *)[self.myFood.comments objectAtIndex:[indexPath row]];
    NSString *text = [NSString stringWithFormat:@"%@:\n%@",comment.byUser.Uname,comment.text];
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %d", (int)indexPath.row]];
    if (!cell) {
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Cell %d", (int)indexPath.row]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentLabel.frame = (CGRect) {.origin = cell.commentLabel.frame.origin, .size = {CGRectGetMinX(cell.likeButton.frame) - CGRectGetMaxY(cell.iconView.frame) - kCommentPaddingFromLeft - kCommentPaddingFromRight,[self tableView:tableView heightForRowAtIndexPath:indexPath] - kCommentCellHeight}};
        cell.commentLabel.text =text;
        cell.timeLabel.frame = (CGRect) {.origin = {CGRectGetMinX(cell.commentLabel.frame), CGRectGetMaxY(cell.commentLabel.frame)}};
        cell.timeLabel.text = @"1d ago";
        [cell.timeLabel sizeToFit];
        
        // Don't judge my magic numbers or my crappy assets!!!
        cell.likeCountImageView.frame = CGRectMake(CGRectGetMaxX(cell.timeLabel.frame) + 7, CGRectGetMinY(cell.timeLabel.frame) + 3, 10, 10);
        cell.likeCountImageView.image = [UIImage imageNamed:@"like_greyIcon.png"];
        cell.likeCountLabel.frame = CGRectMake(CGRectGetMaxX(cell.likeCountImageView.frame) + 3, CGRectGetMinY(cell.timeLabel.frame), 0, CGRectGetHeight(cell.timeLabel.frame));
    }


    
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
    
    
    /*Resize views in scroll view*/
    
    CGFloat sizeMultiplier = (height-190)/( CGRectGetHeight([[UIScreen mainScreen] bounds])-190);
    self.shimmeringView.frame = CGRectMake(CLeftMargin, TitleTopMargin, width-CLeftMargin, ShimmmerViewHeight);
    self.titleLabel.frame = self.shimmeringView.bounds;
    [self.titleLabel setFont:[UIFont fontWithName:PlainTextFontName size:SmallTitleFontSize+(LargeTitleFontSize-SmallTitleFontSize)*sizeMultiplier]];
    
    self.separator.frame = CGRectMake(CLeftMargin, CGRectGetMaxY(self.titleLabel.frame) + BelowShimmmerGap, width-2*CLeftMargin, SeparatorViewHeight);
    
    self.translateLabel.frame = CGRectMake(CLeftMargin, TitleTopMargin + CGRectGetHeight(self.titleLabel.frame)  , width, TranslateLabelHeight);
    
    self.descriptionLabel.frame = CGRectMake(CLeftMargin, CGRectGetHeight(self.titleLabel.frame)+ CGRectGetMaxY(self.titleLabel.frame) + MiddleGAP, width - CLeftMargin*2, TranslateLabelHeight);
    
    self.tagview.frame = CGRectMake(0, BelowDescriptionLabelGap+CGRectGetMaxY(self.descriptionLabel.frame) , width, TagViewHeight);
    
    self.photoCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.tagview.frame) + GAP, width, PhotoCollectionViewHeight);
    

    
    self.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, width,  CGRectGetHeight(self.commentsTableView.frame));
    //
    /*Change alpha values for 4 special views*/
    
    CGFloat newAlpha= (CGRectGetHeight(self.frame)-ViewAlphaRecreaseRate)/(CGRectGetHeight([[UIScreen mainScreen] bounds])-ViewAlphaRecreaseRate);
    self.descriptionLabel.alpha = newAlpha;
    self.tagview.alpha = newAlpha;
    self.commentsTableView.alpha = newAlpha;
    self.photoCollectionView.alpha = newAlpha;

    NSLog(@"+++ FIV %@ +++ LAYOUT SUBVIEW: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.contentSize.height,self.scrollview.frame.size.height);
}

-(void)setUpForLargeLayout{
    self.userInteractionEnabled = YES;
    self.descriptionLabel.hidden = NO;
    self.tagview.hidden = NO;
    self.photoCollectionView.hidden = NO;
     self.commentsTableView.hidden = NO;
}

-(void)setUpForSmallLayout{
    self.userInteractionEnabled = NO;
    self.descriptionLabel.hidden = YES;
    self.tagview.hidden = YES;
    self.photoCollectionView.hidden = YES;
     self.commentsTableView.hidden = YES;
}

/*************** MEi **************/
/*                                */
/*            Rendering           */
/*                                */
/*************** MEi **************/

-(void)setFoodInfo{
    self.titleLabel.text = self.myFood.title;
    self.translateLabel.text = self.myFood.transTitle;
    self.descriptionLabel.text = self.myFood.food_description;
}

//Fetch the comments for first time display
-(void)prepareComments
{
    //If NO comments has been fetched, request them
    if (!self.myFood.isCommentLoaded && !self.myFood.isLoadingComments) {

        //NSLog(@"+++FIV+++ : request comments");
        [self.myFood fetchOldestCommentsSize:NumCommentsPerLoad andSkip:self.myFood.comments.count completion:^(NSError *err, BOOL success) {
            if (success) {
                //NSLog(@"+++FIV+++ : I get %d comments!",(int)self.myFood.comments.count);
                
                CGFloat height = self.myFood.comments.count*kCommentCellMaxHeight;
                self.commentsTableView.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, CGRectGetWidth([[UIScreen mainScreen] bounds]), height);
                //[self.scrollview sizeToFit];
                //self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width, self.scrollview.contentSize.height+height);
                self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width,CGRectGetMaxY(self.commentsTableView.frame)+10);
                [self configCommentTable];
                //NSLog(@"+++ FIV %@+++ PREPARE CMT: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.contentSize.height,self.scrollview.frame.size.height);

            }
            
        }];
    }
}

//Set up comment table delegate
-(void)configCommentTable{
    
    _commentsTableView.delegate = self;
    _commentsTableView.dataSource = self;
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
            CGRect rect = [text boundingRectWithSize:(CGSize){225, kCommentCellMaxHeight}
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]}
                                             context:nil];
            deltaHeight += (int)(CGRectGetHeight(rect)+kCommentCellHeight);
            
        }
        //NSLog(@"+++ FIV +++ : deltaH = %f",deltaHeight);
        self.commentsTableView.frame =  CGRectMake(self.commentsTableView.frame.origin.x, self.commentsTableView.frame.origin.y, self.commentsTableView.frame.size.width, self.commentsTableView.frame.size.height + deltaHeight);
        //self.scrollview.frame =CGRectMake(self.scrollview.frame.origin.x, self.scrollview.frame.origin.y, self.scrollview.frame.size.width, self.scrollview.frame.size.height + deltaHeight);
        self.scrollview.contentSize = CGSizeMake(self.scrollview.contentSize.width, self.scrollview.contentSize.height+deltaHeight);
       // NSLog(@"+++ FIV %@ +++ UPD CMT UI: contentSize H = %f, frame H = %f",self.myFood.title,self.scrollview.contentSize.height,self.scrollview.frame.size.height);
        
        [self.commentsTableView insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

//this method got called when cell preparing for reuse
-(void)cleanUpForReuse{
    
    //set the food object in foodInfoView(belonging to collection cell) to nil
    self.myFood = nil;
    
    //
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

/************  DISPLAY IN COLLECTION VIEW  ************/

// Fist time display, set up photoview delegate
-(void)configPhotoAndTagWithCellNo:(NSInteger)no{
    NSLog(@"test```");
    self.imgLoaderName= [NSString stringWithFormat:@"%d",(int)no];
    //NSLog(@"~~~~~~~~~~CONFIG PHOTO FOR %@ ~~~~~~~~~~~~%d",self.myFood.title,(int)self.myFood.photoNames.count);

    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    
    [self.photoCollectionView reloadData];
    
    [_tagview addTags:self.myFood.tagNames];
    self.descriptionLabel.textColor = [UIColor blackColor];
}

//Prepare data for first time display
-(void)prepareForDisplayInCell:(NSInteger)cellNo{
    if (self.myFood) {
        //Assure title and translation are showed;
        [self setFoodInfo];
        //NSLog(@"******************** !!!!!! setting food !!!!!!00 **********************");
        //If food info is not completed, request it
        if (!self.myFood.isLoadingInfo && !self.myFood.isFoodInfoCompleted) {
            
            [self.myFood fetchAsyncInfoCompletion:^(NSError *err, BOOL success) {
                //NSLog(@"******************** !!!!!! setting food !!!!!!11 **********************");
                if (success) {
                    
                    //NSLog(@"******************** !!!!!! setting food !!!!!!22 **********************");
                    [self setFoodInfo];
                    [self configPhotoAndTagWithCellNo:cellNo];
                    [self prepareComments];
                    [self showCommentButton];
                }
                
            }];
        }
        else if(self.myFood.isFoodInfoCompleted){//Food info is complete, config at once;
            //NSLog(@"******************** !!!!!! setting food !!!!!!333 **********************");
            [self configPhotoAndTagWithCellNo:cellNo];
            [self prepareComments];
            [self showCommentButton];
        }
        
    }
}

/************  DISPLAY IN SINGLE VIEW  ************/
//Prepare data for first time display IN SINGLE FOOD VIEW
-(void)prepareForDisplay{
    if (self.myFood) {
        //Assure title and translation are showed;
        [self setFoodInfo];
        
        //If food info is not completed, request it
        if (!self.myFood.isLoadingInfo && !self.myFood.isFoodInfoCompleted) {
            
            [self.myFood fetchAsyncInfoCompletion:^(NSError *err, BOOL success) {
                if (success) {
                    [self setFoodInfo];
                    [self configPhotoAndTag];
                    [self prepareComments];
                }
                
            }];
        }
        else if(self.myFood.isFoodInfoCompleted){//Food info is complete, config at once;
            [self configPhotoAndTag];
            [self prepareComments];
        }
        
    }
}

// Fist time display, set up photoview delegate
-(void)configPhotoAndTag{
    NSLog(@"test```");
    self.imgLoaderName = @"Default";
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    [_tagview addTags:self.myFood.tagNames];
    self.descriptionLabel.textColor = [UIColor blackColor];
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
    //1. get fid
    
    //2. get uid
    //    User *user = [User sharedInstance];
    //    if(user.Uid != 0){
    //        //show comment button
    //    }
    
    //3.send to server
}

-(void)hideCommentButton{
    self.commentBtn.hidden = YES;
    _commentBtn.alpha = .0f;
    //NSLog(@"------------------------------is hiden = %d",_commentBtn.isHidden);
}

-(void)showCommentButton{
    if ([User sharedInstance].Uid != 1) {
        [UIView animateWithDuration:0.5 animations:^{
            self.commentBtn.hidden = NO;
            self.commentBtn.alpha = 1;
            //NSLog(@"+++++++++++++++++++++++++is hiden = %d",_commentBtn.isHidden);
        }];
    }
    
}

@end
