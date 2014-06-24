

#import "SearchViewController.h"
#import "SSSearchBar.h"
#import "DAKeyboardControl.h"

#define TOOLBAR_HEIGHT 50.f
#define SEARCHBAR_HEIGHT 40.f
#define SEARCHBAR_PADDING 10.f
static NSString * const CellIdentifier = @"Cell";


@interface SearchViewController () <SSSearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) SSSearchBar *searchBar;
@property (strong, nonatomic) UITableView *tableView;

@property (nonatomic) NSArray *data;
@property (nonatomic) NSArray *searchData;

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

    
    self.data = @[ @"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!",@"Hey there!", @"This is a custom UISearchBar.", @"And it's really easy to use...", @"Sweet!" ];
    self.searchData = self.data;
    
    
    [self LoadControls];
    
  
    
}

-(void)LoadControls{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                           0.0f,
                                                                           self.view.bounds.size.width,
                                                                           self.view.bounds.size.height - TOOLBAR_HEIGHT)];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    self.tableView = tableView;
    [self.view addSubview:tableView];
    
    //toolbar
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f,
                                                                     self.view.bounds.size.height - TOOLBAR_HEIGHT,
                                                                     self.view.bounds.size.width,
                                                                     TOOLBAR_HEIGHT)];
    toolBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolBar];
    
    //search bar
    self.searchBar = [[SSSearchBar alloc] initWithFrame:CGRectMake(SEARCHBAR_PADDING,
                                                                   5.0f,
                                                                   toolBar.bounds.size.width - 2*SEARCHBAR_PADDING,
                                                                   SEARCHBAR_HEIGHT)];
    self.searchBar.cancelButtonHidden = NO;
    self.searchBar.placeholder = NSLocalizedString(@"Enter food name", nil);
    self.searchBar.delegate = self;
    [toolBar addSubview:self.searchBar];
    
    
    
    
    self.view.keyboardTriggerOffset = toolBar.bounds.size.height;
    
    [self.view addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
        /*
         Try not to call "self" inside this block (retain cycle).
         But if you do, make sure to remove DAKeyboardControl
         when you are done with the view controller by calling:
         [self.view removeKeyboardControl];
         */
        
        //NSLog(@"yoyo");
        
        CGRect toolBarFrame = toolBar.frame;
        toolBarFrame.origin.y = keyboardFrameInView.origin.y - toolBarFrame.size.height;
        toolBar.frame = toolBarFrame;
        
        CGRect tableViewFrame = tableView.frame;
        tableViewFrame.size.height = toolBarFrame.origin.y;
        tableView.frame = tableViewFrame;
    } constraintBasedActionHandler:nil];
    
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    if([self.searchBar isFirstResponder]){
         [self.searchBar resignFirstResponder];
    }
    
   
}



- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchData count];
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    cell.textLabel.text = self.searchData[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"Avenir Next" size:16];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    [self.tableView reloadData];
}

@end
