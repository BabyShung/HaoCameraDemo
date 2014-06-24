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

static NSString *CellIdentifier = @"Cell";

const CGFloat ScrollViewContentSizeHeight = 1100.f;
const CGFloat kCommentCellHeight = 50.0f;

const CGFloat CLeftMargin = 15.0f;
const CGFloat TitleTopMargin = 10.0f;
const CGFloat GAP = 6.0f;
const CGFloat MiddleGAP = 20.0f;

const CGFloat ShimmmerViewHeight = 30.f;
const CGFloat SeparatorViewHeight = 1.f;
const CGFloat BelowShimmmerGap = 10.f;
const CGFloat TranslateLabelHeight = 70.f;
const CGFloat BelowTranslateGap = 20.f;
const CGFloat DescriptionLabelHeight = 40.f;
const CGFloat BelowDescriptionLabelGap = 20.f;
const CGFloat TagViewHeight = 40.f;
const CGFloat PhotoCollectionViewHeight = 268.f;

static NSString *PlainTextFontName = @"HelveticaNeue-UltraLight";
static NSString *TagTextFontName = @"Heiti TC";
const CGFloat LargeTitleFontSize = 25.f;
const CGFloat LargeTextFontSize = 20.f;
const CGFloat TagFontSize = 18.f;
const CGFloat SmallTitleFontSize = 15.f;
const CGFloat SmallTextFontSize = 40.f;
///*-----*/
////const CGFloat kCommentCellHeight = .088f;
//
//const CGFloat CLeftMargin = .047f;
//const CGFloat TitleTopMargin = .018f;
//const CGFloat GAP = .011;
//const CGFloat MiddleGAP = .035f;
//
//const CGFloat ShimmmerViewHeight = .053f;
//const CGFloat SeparatorViewHeight = 1.f;//FIXED
//const CGFloat BelowShimmmerGap = .018f;
//const CGFloat TranslateLabelHeight = .123f;
//const CGFloat BelowTranslateGap = .035f;
//const CGFloat DescriptionLabelHeight = .07f;
//const CGFloat BelowDescriptionLabelGap = .035f;
///*const CGFloat TagViewHeight = .07f;
//const CGFloat PhotoCollectionViewHeight = .47f;*/

@interface FoodInfoView () <UICollectionViewDataSource,UICollectionViewDelegate,TagViewDelegate,UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray *externalFileURLs;
}
/*current cv must be set up when view appear*/
@property (strong,nonatomic) UIViewController *currentVC;


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
        //init all UI controls
        [self loadControls];
        
    }
    return self;
}

-(void)setVC:(UIViewController *)vc{
    self.currentVC = vc;
}

-(void)loadControls{
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = CGRectGetWidth(self.bounds);
    
    self.scrollview=[[UIScrollView alloc]initWithFrame:self.bounds];
    self.scrollview.showsVerticalScrollIndicator=YES;
    self.scrollview.scrollEnabled=YES;
    self.scrollview.userInteractionEnabled=YES;
    [self addSubview:self.scrollview];
    //should add up all
    self.scrollview.contentSize = CGSizeMake(self.bounds.size.width,ScrollViewContentSizeHeight);
    
    
    CGRect titleRect = CGRectMake(CLeftMargin, TitleTopMargin, self.scrollview.bounds.size.width, ShimmmerViewHeight);
    self.shimmeringView = [[FBShimmeringView alloc] initWithFrame:titleRect];
    self.shimmeringView.shimmering = YES;   //start shimmering
    self.shimmeringView.shimmeringBeginFadeDuration = 0.3;
    self.shimmeringView.shimmeringOpacity = 0.3;
    self.shimmeringView.backgroundColor = [UIColor clearColor];
    [self.scrollview addSubview:self.shimmeringView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    self.titleLabel.text = @"Blue Cheese";
    self.titleLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTitleFontSize];
    self.titleLabel.textColor = [UIColor blackColor];
    //self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.backgroundColor = [UIColor clearColor];
    _shimmeringView.contentView = self.titleLabel;
    
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(CLeftMargin, CGRectGetMaxY(self.titleLabel.frame) + BelowShimmmerGap, CGRectGetWidth(self.scrollview.frame)-2*CLeftMargin, SeparatorViewHeight)];
    self.separator.backgroundColor = [UIColor blackColor];
    [self.scrollview addSubview:self.separator];
    
    self.translateLabel = [[UILabel alloc] initWithFrame:CGRectMake(CLeftMargin, TitleTopMargin + CGRectGetHeight(self.titleLabel.frame)  , self.scrollview.bounds.size.width, TranslateLabelHeight)];
    self.translateLabel.text = @"蓝芝士";
    self.translateLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTextFontSize];
    self.translateLabel.textColor = [UIColor blackColor];
    //self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.translateLabel.backgroundColor = [UIColor clearColor];
    [self.scrollview addSubview:self.translateLabel];
    //_shimmeringView.contentView = self.translateLabel;
    
/*--------------------------------------------------------------------------------------------*/
    
    self.descriptionLabel = [[RQShineLabel alloc] initWithFrame:CGRectMake(CLeftMargin, CGRectGetHeight(self.titleLabel.frame)+ CGRectGetMaxY(self.titleLabel.frame) + MiddleGAP, CGRectGetWidth(self.scrollview.frame) - CLeftMargin*2, TranslateLabelHeight)];
    self.descriptionLabel.numberOfLines = 0;
    self.descriptionLabel.text = @"";
    self.descriptionLabel.font = [UIFont fontWithName:PlainTextFontName size:LargeTextFontSize];
    self.descriptionLabel.backgroundColor = [UIColor clearColor];
    //self.descriptionLabel.hidden = YES;
    //label.center = self.view.center;
    //self.descriptionLabel.textColor = [UIColor grayColor];
    
    [self.scrollview addSubview:self.descriptionLabel];
    
    
    _tagview = [[TagView alloc]initWithFrame:CGRectMake(0, BelowDescriptionLabelGap+CGRectGetMaxY(self.descriptionLabel.frame) , CGRectGetWidth(self.bounds), TagViewHeight)];
    _tagview.allowToUseSingleSpace = YES;
    _tagview.delegate = self;
    [_tagview setFont:[UIFont fontWithName:TagTextFontName size:TagFontSize]];
    [_tagview setBackgroundColor:[UIColor clearColor]];
    [self.scrollview addSubview:_tagview];
    
    
    //collectionView + layout
    EDImageFlowLayout *small = [[EDImageFlowLayout alloc]init];
    
    self.photoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tagview.frame) + GAP, CGRectGetWidth(self.bounds), PhotoCollectionViewHeight) collectionViewLayout:small];
    [self.photoCollectionView registerClass:[EDImageCell class] forCellWithReuseIdentifier:CellIdentifier];
    self.photoCollectionView.backgroundColor = [UIColor clearColor];
    
    [self.photoCollectionView setShowsHorizontalScrollIndicator:NO];
    [self.scrollview addSubview:self.photoCollectionView];
    
    //init all the image paras
    externalFileURLs = [NSMutableArray array];
    
    NSString *namesString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fullURLs" ofType:@"txt"] encoding:NSUTF8StringEncoding error:nil];
    NSArray *fileNamesArray = [namesString componentsSeparatedByString:@"\n"];
    
    for (int i = 0; i < fileNamesArray.count; i++) {
        NSString *urlString = fileNamesArray[i];
        NSURL *url = [NSURL URLWithString:urlString];
        [externalFileURLs addObject:url];
    }
    
    //add table view
    //----------------------------comment
    _commentsViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) )];

    //_commentsViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + 6.f,320, 568 )];
    //[_commentsViewContainer addGradientMaskWithStartPoint:CGPointMake(0.5, 0.0) endPoint:CGPointMake(0.5, 0.03)];
    //************** pay attention to tableview *****************
    //_commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) ) style:UITableViewStylePlain];
    _commentsTableView = [[UITableView alloc] initWithFrame:_commentsViewContainer.frame style:UITableViewStylePlain];
    _commentsTableView.scrollEnabled = NO;
    
    _commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _commentsTableView.separatorColor = [UIColor clearColor];
    
    //********* finally put in self.view ************
    [_commentsViewContainer addSubview:_commentsTableView];
    [self.scrollview addSubview:_commentsViewContainer];
    
    // Let's put in some fake data!
    _comments = [@[@"Oh my god! Me too!", @"I happened to be one of the coolest guy to learn this shit!", @"More comments", @"Go Toronto Blue Jays!", @"I rather stay home", @"I don't get what you are saying", @"I don't have an iPhone"] mutableCopy];
}

/*!!!!! Fist time display !!!!!*/
-(void)configureNetworkComponents{
    NSLog(@"test```");
//    self.photoCollectionView.delegate = self;
//    self.photoCollectionView.dataSource = self;
    _commentsTableView.delegate = self;
    _commentsTableView.dataSource = self;
    [_commentsTableView reloadData];
    
    [_tagview addTags:@[@"蓝色", @"臭",@"酸",@"软", @"难消化",@"高热量",@"发酵品"]];
    
    self.descriptionLabel.text = @"蓝芝士是一种听上去很好吃但是味道很恶心的芝士。";
    
    [self.descriptionLabel sizeToFit];
    [self.descriptionLabel shine];
    
    
    NSLog(@"visible %d",self.descriptionLabel.isVisible);
}

/**********************************
 
 collectionView delegate
 
 ************************/
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EDImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //dispatch_async(dispatch_get_main_queue(), ^{
    cell.activityView.hidden = NO;
    [cell.activityView startAnimating];
    //});
    //Set the loading image
    //cell.imageView.image = loadingImage;
    
    //Cancel any other previous downloads for the image view.
    [cell.imageView cancelLoadingAllImages];
    
    //Load the new image
    [cell.imageView loadImageFromURLAtAmazonAsync:externalFileURLs[indexPath.row] completion:^(BOOL success, M13AsynchronousImageLoaderImageLoadedLocation location, UIImage *image, NSURL *url, id target) {
        //This is where you would refresh the cell if need be. If a cell of basic style, just call "setNeedsRelayout" on the cell.
        
        cell.activityView.hidden = YES;
        [cell.activityView stopAnimating];
        
        
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
    return externalFileURLs.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}




/**********************************
 
 tagView delegate
 
 ************************/
#pragma mark - HKKTagWriteViewDelegate
- (void)tagWriteView:(TagView *)view didMakeTag:(NSString *)tag
{
    //NSLog(@"added tag = %@", tag);
}

- (void)tagWriteView:(TagView *)view didRemoveTag:(NSString *)tag
{
    //NSLog(@"removed tag = %@", tag);
}


/**********************************
 
 tableview delegate
 
 ************************/
#pragma mark

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *text = [_comments objectAtIndex:[indexPath row]];
    CGRect rect = [text boundingRectWithSize:(CGSize){225, MAXFLOAT}
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16.f]}
                                     context:nil];
    CGSize requiredSize = rect.size;
    return kCommentCellHeight + requiredSize.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"Cell %d", indexPath.row]];
    if (!cell) {
        cell = [[CommentCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"Cell %d", indexPath.row]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentLabel.frame = (CGRect) {.origin = cell.commentLabel.frame.origin, .size = {CGRectGetMinX(cell.likeButton.frame) - CGRectGetMaxY(cell.iconView.frame) - kCommentPaddingFromLeft - kCommentPaddingFromRight,[self tableView:tableView heightForRowAtIndexPath:indexPath] - kCommentCellHeight}};
        cell.commentLabel.text = _comments[indexPath.row];
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


-(void)updateUIForFrame:(CGRect)rect{
    CGFloat width = CGRectGetWidth(rect);
    CGFloat height = CGRectGetHeight(rect);
    [self setFrame:rect];
    [self.scrollview setFrame:self.bounds];
    [self.scrollview setContentSize:CGSizeMake(CGRectGetWidth(rect),ScrollViewContentSizeHeight)];
//    NSLog(@"FOOD view (%f, %f) size: %f,%f", self.scrollview.frame.origin.x,self.scrollview.frame.origin.y,self.scrollview.contentSize.height, self.scrollview.contentSize.width);
    self.shimmeringView.frame = CGRectMake(CLeftMargin, TitleTopMargin, self.frame.size.width, ShimmmerViewHeight);
    self.titleLabel.frame = self.shimmeringView.bounds;
    self.separator.frame = CGRectMake(CLeftMargin, CGRectGetMaxY(self.titleLabel.frame) + BelowShimmmerGap, CGRectGetWidth(self.frame)-2*CLeftMargin, SeparatorViewHeight);
    self.translateLabel.frame = CGRectMake(CLeftMargin, TitleTopMargin + CGRectGetHeight(self.titleLabel.frame)  , self.bounds.size.width, TranslateLabelHeight);    
    self.descriptionLabel.frame = CGRectMake(CLeftMargin, CGRectGetHeight(self.titleLabel.frame)+ CGRectGetMaxY(self.titleLabel.frame) + MiddleGAP, CGRectGetWidth(self.scrollview.frame) - CLeftMargin*2, TranslateLabelHeight);
    self.tagview.frame = CGRectMake(0, BelowDescriptionLabelGap+CGRectGetMaxY(self.descriptionLabel.frame) , CGRectGetWidth(self.bounds), TagViewHeight);
    self.photoCollectionView.frame = CGRectMake(0, CGRectGetMaxY(self.tagview.frame) + GAP, CGRectGetWidth(self.bounds), PhotoCollectionViewHeight);
    self.commentsViewContainer.frame = CGRectMake(0, CGRectGetMaxY(self.photoCollectionView.frame) + GAP, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) );
    self.commentsTableView.frame = self.commentsViewContainer.bounds;
    
    //self.scrollview.backgroundColor = [UIColor blueColor];

}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{

}
//-(void)layoutSubviews{
//    [self.scrollview setContentSize:self.frame.size];
//    NSLog(@"FOOD view (%f, %f) size: %f,%f", self.frame.origin.x,self.frame.origin.y,self.scrollview.contentSize.height, self.scrollview.contentSize.width);
//}


-(void)setUpForLargeLayout{
    self.userInteractionEnabled = YES;
//    self.scrollview.scrollEnabled = YES;
    self.descriptionLabel.hidden = NO;
    self.tagview.hidden = NO;
    self.photoCollectionView.hidden = NO;
    self.commentsViewContainer.hidden = NO;
}

-(void)setUpForSmallLayout{
    self.userInteractionEnabled = NO;
//    self.scrollview.scrollEnabled = NO;
    self.descriptionLabel.hidden = YES;
    self.tagview.hidden = YES;
    self.photoCollectionView.hidden = YES;
    self.commentsViewContainer.hidden = YES;
}
@end
