//
//  LanguageViewController.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 7/19/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageCell.h"
#import "LoadControls.h"
#import "ShareData.h"
#import "languageSetting.h"
#import "UIView+Toast.h"

const NSString *langCellIdentity = @"Cell";

@interface LanguageViewController ()

@property (strong,nonatomic) NSArray *languages;

@property (nonatomic) TargetLang targetLanguage;

@property (nonatomic,strong) UIImage *checkImage;

@property (nonatomic,strong) languageSetting *langSettings;

@end

@implementation LanguageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    backgroundView.image = [UIImage imageNamed:@"blackBG.JPG"];
    [self.view insertSubview:backgroundView belowSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.languages = [NSArray arrayWithObjects:
                      @"中文",
                      @"English",
                      nil];
    
    [self loadControls];
    
    self.langSettings = [[languageSetting alloc]init];
    
    //chinese 1, english 2
    self.targetLanguage = [self.langSettings getAppLanguage] - 1;
    
    self.checkImage = [UIImage imageNamed:@"check_black.png"];
}

-(void)loadControls{
    UIButton *btn = [LoadControls createRoundedBackButton];
    [btn addTarget:self action:@selector(previousPagePressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:btn aboveSubview:self.collectionView];
}

- (void) previousPagePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UICollectionViewDataSource Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.languages count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LanguageCell *cell = (LanguageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[langCellIdentity copy] forIndexPath:indexPath];
    cell.languageTitleLabel.text = [self.languages objectAtIndex:indexPath.row];
    
    if(self.targetLanguage==indexPath.row){
        cell.languageCheckImageView.image = self.checkImage;
    }else{
        cell.languageCheckImageView.image = nil;
    }
    
    return cell;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
 
    self.targetLanguage = indexPath.row;
    
    if([self.langSettings setAppLanguage:self.targetLanguage+1]){
        [self.view makeToast:AMLocalizedString(@"LANGUAGE_SETTING_DONE", nil)];
    }
    [self.collectionView reloadData];
    
}

@end
