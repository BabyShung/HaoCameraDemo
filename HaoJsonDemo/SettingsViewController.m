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
#import "AppDelegate.h"

const NSString *settingCellIdentity = @"Cell";

@interface SettingsViewController ()

@property (strong,nonatomic) NSArray *settings;
@property (strong,nonatomic) NSArray *settingsImages;


@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image = [UIImage imageNamed:@"blackBG.JPG"];
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //disable pageVC scroll and also stop camera
    [GeneralControl enableBothCameraAndPageVCScroll:NO];
    
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
    UIButton *btn = [LoadControls createRoundedBackButton];
    [btn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:btn aboveSubview:self.collectionView];

}

- (void) previousPagePressed:(id)sender {
    
    [GeneralControl enableBothCameraAndPageVCScroll:YES];
    
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
        UIViewController *auvc = [self.storyboard instantiateViewControllerWithIdentifier:@"languageVC"];
        auvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:auvc animated:YES completion:nil];
        
    }else if (index == 1){
        
        introContainer *ic = [[introContainer alloc] initWithFrame:self.view.bounds];
        ic.shouldShowHint = NO;
        [self.view addSubview:ic];
        [ic showIntroWithCrossDissolve];
        
    }else if (index == 2){
        UIViewController *auvc = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutUs"];
        auvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:auvc animated:YES completion:nil];
    }
    
}


@end
