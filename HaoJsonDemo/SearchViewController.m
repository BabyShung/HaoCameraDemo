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
#import "SingleFoodViewController.h"
#import "DBOperation.h"
#import "Dictionary.h"
#import "GeneralControl.h"

#define FETCH_SEARCH_NUMBER 20

#define BackBtn_offset 215

static NSString *CellIdentifier = @"Cell";

@interface SearchViewController () <SSSearchBarDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet SSSearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UIButton *backBtn;

@property (nonatomic) NSArray *foodData;

@property (nonatomic) NSMutableArray *searchData;

@property (nonatomic) Dictionary *dict;

@property (nonatomic) DBOperation *dbo;

@property (nonatomic) CGFloat backBtn_Y;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self loadControls];
    
    self.dbo = [[DBOperation alloc] init];
    self.foodData = [self.dbo fetchSearchHistoryByOrder_withLimitNumber:FETCH_SEARCH_NUMBER];
    self.searchData = [NSMutableArray arrayWithArray:self.foodData];
    self.dict = [[Dictionary alloc]initDictInDefaultLang];
    
    //disable pageVC scroll and also stop camera
    [GeneralControl enableBothCameraAndPageVCScroll:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [self.searchBar becomeFirstResponder];
}

- (void) previousPagePressed:(id)sender {
    
    //enable pageVC scroll and also start camera
    [GeneralControl enableBothCameraAndPageVCScroll:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(BOOL)searchBarShouldBeginEditing:(SSSearchBar *)searchBar{
    if(self.backBtn.center.y == self.backBtn_Y){
        [UIView animateWithDuration:.5 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _backBtn.center = CGPointMake(_backBtn.center.x, _backBtn.center.y - BackBtn_offset);
        } completion:nil];
    }
    return YES;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self resignKeyboard];
    
    if(self.backBtn.center.y == self.backBtn_Y - BackBtn_offset){
        [UIView animateWithDuration:.5 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
            _backBtn.center = CGPointMake(_backBtn.center.x, _backBtn.center.y + BackBtn_offset);
        } completion:nil];
    }
}

-(void)resignKeyboard{
    if([self.searchBar isFirstResponder]){
        [self.searchBar resignFirstResponder];
    }
}

#pragma mark - SSSearchBarDelegate
- (void)searchBarCancelButtonClicked:(SSSearchBar *)searchBar {
    self.searchBar.text = @"";
    [self.searchData removeAllObjects];
    [self.searchData addObjectsFromArray:[self.dbo fetchSearchHistoryByOrder_withLimitNumber:FETCH_SEARCH_NUMBER]];
    
    [self.collectionView reloadData];
    //[self filterTableViewWithText:self.searchBar.text];
}
- (void)searchBarSearchButtonClicked:(SSSearchBar *)searchBar {
    
    //also search in db and send server request
    
    [self.searchBar resignFirstResponder];
    if ([self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self.view makeToast:AMLocalizedString(@"EMPTY_SEARCH_TERM",nil) duration:0.3 position:@"center"];
    }
    else if (self.searchData.count > 0 && [((Food *)self.searchData[0]).title caseInsensitiveCompare:self.searchBar.text] == NSOrderedSame) {
        //Perfect match found locally
        //Open detailed FIV immediately
        
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionTop];
        [self performSegueWithIdentifier:@"toSingleFoodSegue" sender:self];
        
    }else{
        
        //NO Pergect Matched result in localDB
        //Send search terms to Server
        [self.view makeToastActivity];
        
        [self.dict serverSearchOCRString:self.searchBar.text andCompletion:^(NSArray *results, BOOL success) {
            
            [self.view hideToastActivity];
            
            if (success) {
                if(results.count == 0){
                    [self.view makeToast:AMLocalizedString(@"NO_SEARCH_RESULT", nil) duration:0.3 position:@"center"];
                }
                else {
                    [self.searchData removeAllObjects];
                    [self.searchData addObjectsFromArray:results];
                    [self.collectionView reloadData];
                    
                    if([((Food *)results[0]).title caseInsensitiveCompare:self.searchBar.text] == NSOrderedSame){
                        
                        //Server return a perfect matched result!
                        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionTop];
                        [self performSegueWithIdentifier:@"toSingleFoodSegue" sender:self];
                    }
                }
            }
            else{
                [self.view makeToast:AMLocalizedString(@"SEARCH_FAILURE", nil) duration:0.3 position:@"bottom"];
            }
        }];
    }
}

- (void)searchBar:(SSSearchBar *)searchBar textDidChange:(NSString *)searchText {
    //[self filterTableViewWithText:searchText];
    [self.searchData removeAllObjects];
    
    if ([searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        //Terms in search bar is empty, show search history
        
        [self.searchData addObjectsFromArray:[self.dbo fetchSearchHistoryByOrder_withLimitNumber:FETCH_SEARCH_NUMBER]];
    }
    else{
        [self.searchData addObjectsFromArray:[self.dict localBlurSearchString:searchText]];
    }
    [self.collectionView reloadData];
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
    
    //Not Dislay query label if it is a new food
    if (food.queryTimes > 0) {
        cell.queryLabel.text = [NSString stringWithFormat:@"%d%@",(int)food.queryTimes,food.queryTimes>1?AMLocalizedString(@"TIMES", nil):AMLocalizedString(@"TIME", nil)];
    }
    else{
        cell.queryLabel.text = @"";
    }
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.destinationViewController isKindOfClass:[SingleFoodViewController class]]) {
        
        // Get the selected item index path
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        
        // Set the thing on the view controller we're about to show
        if (selectedIndexPath != nil) {
            SingleFoodViewController *sfvc = segue.destinationViewController;
            sfvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            Food *selectedFood = self.searchData[selectedIndexPath.row];
            
            sfvc.currentFood = selectedFood;
            
            DBOperation *dbo = [[DBOperation alloc] init];
            [dbo upsertSearchHistory:selectedFood];
            
            //finally manually click clear btn
            [self searchBarCancelButtonClicked:nil];
        }
    }
}

#pragma mark - Helper Methods

-(void)loadControls{
    _backBtn = [LoadControls createRoundedBackButton];
    [_backBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backBtn_Y = self.backBtn.center.y;
    
    [self.view addSubview:_backBtn];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    //it can scroll even when the height is less than frame height
    self.collectionView.alwaysBounceVertical = YES;
    
    self.searchBar.cancelButtonHidden = NO;
    self.searchBar.placeholder = AMLocalizedString(@"Search food", nil);
    self.searchBar.delegate = self;
}

@end
