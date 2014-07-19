//
//  SettingsViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/19/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "SettingsViewController.h"
#import "LocalizationSystem.h"
#import "SettingsCell.h"
#import "introContainer.h"
#import "GeneralControl.h"
#import "LoadControls.h"
#import "ED_Color.h"

const NSString *settingCellIdentity = @"Cell";

@interface SettingsViewController ()

@property (strong, nonatomic) UIButton *backBtn;

@property (strong,nonatomic) NSArray *settings;
@property (strong,nonatomic) NSArray *settingsImages;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[GeneralControl setPageViewControllerScrollEnabled:NO];
    
    self.settings = [NSArray arrayWithObjects:
                           AMLocalizedString(@"LANGUAGUE_SETTING",nil),
                           AMLocalizedString(@"TUTORIAL_STRING", nil),
                           AMLocalizedString(@"CARD_ABOUT", nil),
                     nil];
    self.settingsImages = [NSArray arrayWithObjects:
                                 [UIImage imageNamed:@"ED_switchLanguage.png"],
                                 [UIImage imageNamed:@"ED_tutorial.png"],
                                 [UIImage imageNamed:@"ED_aboutUs.png"],
                           nil];
    [self loadControls];
}

-(void)loadControls{
    _backBtn = [LoadControls createRoundedButton_Image:@"CameraPrevious.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 10, 9, 13) andLeftBottomElseRightBottom:YES];
    [_backBtn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_backBtn aboveSubview:self.collectionView];

}
- (void) previousPagePressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.settings count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SettingsCell *cell = (SettingsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[settingCellIdentity copy] forIndexPath:indexPath];
    cell.settingTitleLabel.text = [self.settings objectAtIndex:indexPath.row];
    cell.settingTitleImage.image = self.settingsImages[indexPath.row];
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    NSUInteger index = indexPath.row;
    
    if (index == 0){
        
        
    }else if (index == 1){
        
        introContainer *ic = [[introContainer alloc] initWithFrame:self.view.bounds];
        ic.shouldShowHint = NO;
        [self.view addSubview:ic];
        [ic showIntroWithCrossDissolve];
        
    }else if (index == 2){

    }
    
    
}


@end
