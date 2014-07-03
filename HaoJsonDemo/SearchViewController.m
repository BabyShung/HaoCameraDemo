//
//  SearchViewController.m
//  SSSearchBarExample
//
//  Created by Hao Zheng on 7/2/14.
//  Copyright (c) 2014 Simon Gislen. All rights reserved.
//

#import "SearchViewController.h"
#import "SSSearchBar.h"
#import "SearchCell.h"
#import "LoadControls.h"
#import "ED_Color.h"
#import "DBOperation.h"

static NSString *CellIdentifier = @"Cell";

@interface SearchViewController () <SSSearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet SSSearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UIButton *backBtn;

@property (nonatomic) NSArray *data;

@property (nonatomic) NSArray *searchData;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadControls];
    
    
    DBOperation *dbo = [[DBOperation alloc] init];
    
    
    self.data = [dbo fetchSearchHistoryByOrder_withLimitNumber:10];
    self.searchData = self.data;
    

}

-(void)loadControls{
    _backBtn = [LoadControls createCameraButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andCenter:CGPointMake(10+20, CGRectGetHeight([[UIScreen mainScreen] bounds])-8-20) andSmallRadius:YES];
    [_backBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backBtn];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    
    self.searchBar.cancelButtonHidden = NO;
    self.searchBar.placeholder = NSLocalizedString(@"Search food", nil);
    self.searchBar.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [self.searchBar becomeFirstResponder];
    
    [UIView animateWithDuration:.5 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
        _backBtn.center = CGPointMake(_backBtn.center.x, iPhone5? 320: 200);
    } completion:^(BOOL finished) {
        if (finished) {

        }
    }];
}

- (void) previousPagePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self resignKeyboard];
}

-(void)resignKeyboard{
    if([self.searchBar isFirstResponder]){
        [self.searchBar resignFirstResponder];
    }
}
#pragma mark - SSSearchBarDelegate

- (void)searchBarCancelButtonClicked:(SSSearchBar *)searchBar {
    self.searchBar.text = @"";
    [self filterTableViewWithText:self.searchBar.text];
}
- (void)searchBarSearchButtonClicked:(SSSearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
}
- (void)searchBar:(SSSearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterTableViewWithText:searchText];
}


-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [self.searchData count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    SearchCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Food *food = self.searchData[indexPath.row];
    cell.titleLabel.text = food.title;
    cell.transLabel.text = food.transTitle;
    cell.queryLabel.text = [NSString stringWithFormat:@"%d次",(int)food.queryTimes];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"click %d",(int)indexPath.row);
}

#pragma mark - Helper Methods

- (void)filterTableViewWithText:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        self.searchData = self.data;
    }
    else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", searchText];
        self.searchData = [self.data filteredArrayUsingPredicate:predicate];
    }
    
    [self.collectionView reloadData];
}

@end
