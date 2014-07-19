//
//  MainViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.

#import "MainViewController.h"
#import "largeLayout.h"
#import "TransitionController.h"
#import "debugView.h"
#import "EDCollectionCell.h"
#import "TransitionLayout.h"
#import "SecondViewController.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import "ImagePreProcessor.h"
#import "TextDetector2.h"
#import "WordCorrector.h"
#import "Dictionary.h"
#import "Food.h"
#import "ED_Color.h"
#import "LoadControls.h"
#import "AppDelegate.h"
#import "M13AsyncImageLoader.h"
#import "LoadControls.h"
#import "SearchDictionary.h"
#import "User.h"
#import "UIView+Toast.h"
#import "Flurry.h"
#import "LocalizationSystem.h"
#import "NSUserDefaultControls.h"

#import "HintView.h"
#import "EAIntroView.h"
#import "SMPageControl.h"


static NSString *CellIdentifier = @"Cell";

@interface MainViewController () <TransitionControllerDelegate,EdibleCameraDelegate,EAIntroDelegate>
{
    CGFloat ScreenWidth;
    CGFloat ScreenHeight;
}
@property (strong, nonatomic) UIButton * clearBtn;

@property (strong, nonatomic) UIButton * nextBtn;

@property (strong,nonatomic) Tesseract *tesseract;

@property (strong,nonatomic) NSMutableArray *imgArray;

@property (strong,nonatomic) ImagePreProcessor *ipp;

@property (nonatomic) cv::Mat tempMat;

@property (nonatomic,strong) debugView *debugV;

@property (strong,nonatomic) NSMutableArray *foodArray;

@property (strong,nonatomic) NSMutableDictionary *existingFood;

@property (strong,nonatomic) TransitionController *transitionController;

@property (strong,nonatomic) TextDetector2 *textDetector2;

@property (nonatomic) NSUInteger counterForNoResult;


@end

@implementation MainViewController


- (void)viewDidLoad{
    
    ScreenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    ScreenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    
    //init textDetector - ChutianGao
    _textDetector2 = [[TextDetector2 alloc]init];
    
    //setup tesseract
    [self loadTesseract];
    
    //init controls, *camera*
    [self loadControls];
    
    //set camView delegate to be DEBUG_VC
    [self.Maindelegate setCamDelegateFromMain:self];
    
    //if first launch, show it
    if([NSUserDefaultControls isFirstLaunch]){
        [NSUserDefaultControls userFinishFirstLaunch];
        
        [self showIntroWithCrossDissolve];
    }
    
}

-(void)loadControls{
    self.camView = [[CameraView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) andOrientation:self.interfaceOrientation andAppliedVC:self];
    [self.view insertSubview:self.camView belowSubview:self.collectionView];
    
    /*REQUIRED FOR DEBUGGING ANIMATION*/
    
    self.collectionView.hidden = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //registering dequueue cell
    [self.collectionView registerClass:[EDCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    //debug view
    //self.debugV = [[debugView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) andReferenceCV:self];
    //[self.view insertSubview:self.debugV aboveSubview:self.collectionView];
    //NSLog(@"+++ MVC +++ : I init transition controller");
    
    self.transitionController = [[TransitionController alloc] initWithCollectionView:self.collectionView];
    self.transitionController.delegate = self;
    self.navigationController.delegate = self.transitionController;
    
    //add in collectionView
    
    _clearBtn = [LoadControls createRoundedButton_Image:@"ED_cross.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(10, 10, 10, 10) andLeftBottomElseRightBottom:YES];
    [_clearBtn addTarget:self action:@selector(clearBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _clearBtn.alpha = 1;
    _clearBtn.hidden = YES;
    [self.view insertSubview:_clearBtn aboveSubview:self.collectionView];
    
    
    _nextBtn = [LoadControls createRoundedButton_Image:@"CameraNext.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(9, 13, 9, 10) andLeftBottomElseRightBottom:NO];
    [_nextBtn addTarget:self action:@selector(nextBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _nextBtn.alpha = 1;
    _nextBtn.hidden = YES;
    [self.view insertSubview:_nextBtn aboveSubview:self.collectionView];
}

- (void) clearBtnPressed:(id)sender {
    
    [Flurry logEvent:@"Clear_Btn_Pressed"];  
    
    //save searchHistory and clear
    [SearchDictionary saveSearchHistoryToLocalDB];
    
    [self.camView resumeCamera];
    [self.camView backBtnPressed:nil];
    
    //Clean up cached comments of different foods
    NSLog(@"+++++++ MVC +++++++++ : clean up last comntes");
    [[User sharedInstance].lastComments removeAllObjects];
    
    
    [self hideResultButtonsAndCollectionView];

    self.existingFood =nil;
    
    [self.foodArray removeAllObjects];
    [self.collectionView reloadData];
    
    
    //[M13AsyncImageLoader cleanupLoaderAll];
}

//right bottom button
- (void) nextBtnPressed:(id)sender {
    [self.camView nextPagePressed:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        HintView *hv = [[HintView alloc] initWithFrame:self.view.frame];
//        [self.view addSubview:hv];
//        
//        [hv updateSpotLightWithPoint:CGPointMake(250, 100)];
//    });
    

    
    
    
    
    
    //[self.camView startLoadingAnimation];
    
    [self.view bringSubviewToFront:_clearBtn];
    [self.view bringSubviewToFront:_nextBtn];
    
    //scroll DEspeed normal
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.camView.StreamView.alpha = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            if ([(NSObject *)self.camView.camDelegate respondsToSelector:@selector(EdibleCameraDidLoadCameraIntoView:)]) {
                [self.camView.camDelegate EdibleCameraDidLoadCameraIntoView:self];
            }
        }
    }];
    
}

/*******************************
 
 collection view delegate
 
 *****************************/
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.foodArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    EDCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

    [cell configFIVForCell:indexPath.row withFood:self.foodArray[indexPath.row]];
    
//    if (cell.frame.size.height == [[UIScreen mainScreen] bounds].size.height) {
//        if (cell.foodInfoView.myFood.isFoodInfoCompleted) {
//            cell.foodInfoView.loadingBtn.hidden = YES;
//        }
//        else{
//            cell.foodInfoView.loadingBtn.hidden = NO;
//        
//        }
//        //NSLog(@"============================================ large cell reused!!!!!!!!!!!!!!!!!!");
//    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //close camera
    [self.camView pauseCamera];
    
    //save in search history
    EDCollectionCell *cell = (EDCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    [SearchDictionary addSearchHistory:cell.foodInfoView.myFood];
    
    //present secondVC
    SecondViewController *viewController = [[SecondViewController alloc] initWithCollectionViewLayout:[[largeLayout alloc] init]];
    viewController.useLayoutToLayoutNavigationTransitions = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}

//delegate method, after calling startInteractiveTransition, will call this
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    UIViewController *topVC = [self.navigationController topViewController];
    if ([topVC class] ==[MainViewController class]) {
        return nil;
    }
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

//Add new items into collection view
//This method will exclude duplicates results
-(void)addFoodItems:(NSArray *) newFoodItems
{
    if (newFoodItems.count>0) {
        
        NSInteger startIndex = self.foodArray.count;
        
        NSMutableArray *newIndexPaths = [[NSMutableArray alloc]init];
        NSMutableArray *addItems = [[NSMutableArray alloc]initWithArray:newFoodItems];
        
        int count = (int)addItems.count;
        for (int i =0; i<count; i++){
            Food *food = addItems[i];
            if (![self.existingFood valueForKey:[food.title lowercaseString]]) {
                [self.existingFood setValue:@"1" forKey:[food.title lowercaseString]];
                [newIndexPaths addObject:[NSIndexPath indexPathForItem:(startIndex+i) inSection:0]];
                
            }
            else{
                [addItems removeObjectAtIndex:i];
                i--;
                count--;
            }
        }
        // NSLog(@"+++ MAIN VC +++ : -newFoodItems.count: %d",(int)addItems.count);
        
        [self.collectionView performBatchUpdates:^{
            [self.foodArray addObjectsFromArray:addItems];
            [self.collectionView insertItemsAtIndexPaths:newIndexPaths];
            
        } completion:nil];
    }
}

//transitionVC delegate
- (void)interactionBeganAtPoint:(CGPoint)point
{
    // NSLog(@"+++ MVC +++ : POP transition interaction will begin");
    //    UIViewController *topVC = [self.navigationController topViewController];
    //    if ([topVC class] != [MainViewController class]) {
    [self.navigationController popViewControllerAnimated:YES];
    //    }
}

-(void)loadTesseract{
    _tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];//langague package
    [_tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz,.&-" forKey:@"tessedit_char_whitelist"]; //limit search
}

#pragma mark --------- Tesseract
//tesseract processing
-(NSString *)recognizeImageWithTesseract:(UIImage *)img
{
    [_tesseract setImage:img]; //image to check
    [_tesseract recognize];//processing
    NSString *recognizedText = [_tesseract recognizedText];
    NSLog(@"Tesseract Recognized: %@", recognizedText);
    return recognizedText;
}

#pragma mark CAMERA DELEGATE

- (void) EdibleCamera:(MainViewController *)simpleCam didFinishWithImage:(UIImage *)image withRect:(CGRect)rect andCropSize:(CGSize)size{

    /****** OCR and Searching Components *****/
    
    Dictionary *dict = [[Dictionary alloc]initDictInDefaultLang];
//    //@"yeast bread with Worcestershire sauce and yogurt"
 //   [dict serverSearchOCRString:@"Romano and flatbread and roll and Romano Cheese" andCompletion:^(NSArray *results, BOOL success) {
//        //NSLog(@"++++Main VC++++ : Server Foods: %d",(int)results.count);
//        [self addFoodItems:results];
//    }];
    
    
    
    /**********************************/
//    NSArray *localFoods = [dict localSearchOCRString:@"Romano and flatbread and roll and Romano Cheese"];
////    NSLog(@"++++Main VC++++ : Local Foods: %d",(int)localFoods.count);
//    [self addFoodItems:localFoods];
//    [self showResultButtonsAndCollectionView];



    
    //also add two btns, one cross:clear cell, and one capture:
    //NSMutableArray *localFoods = [NSMutableArray array];
    

//    if (image) {
//        
//        
//        //PS: image variable is the original size image (2448*3264)
//        UIImage *onScreenImage = [LoadControls scaleImage:image withScale:2.5f withRect:rect andCropSize:size];
//        UIImage *originalImage = [UIImage imageWithCGImage:onScreenImage.CGImage];
//        NSMutableArray *localFoods = [NSMutableArray array];
//        self.imgArray = [self.textDetector2 findTextArea:originalImage];
//        NSLog(@"+++ MAIN VC +++ : text areas %d",(int)self.imgArray.count);
//        if ([_imgArray count] > 0)
//        {
//            for(UIImage *preImage in _imgArray){
//                
//                _tempMat= [preImage CVMat];
//                
//                // Step 3. put Mat into pre processor- Charlie
//                _tempMat = [self.ipp processImage:_tempMat];
//                NSString *ocrStr = [self recognizeImageWithTesseract:[UIImage imageWithCVMat:_tempMat]];
//                NSLog(@" ++++++++++ MAIN VC +++++++++++ : TEESSACT REC: %@",ocrStr);
//                
//                [localFoods addObjectsFromArray:[dict localSearchOCRString:ocrStr]];
//            }
//            //hao added
//            [self.camView stopLoadingAnimation];
//            
//            [self showResultButtons];
//            
//            [self addFoodItems:localFoods];
//            
//        }else{
//            //no image coming back, tell users to retake
//            
//            [self.view makeToast:AMLocalizedString(@"DETECTOR_NO_RESULT", nil)];
//        }
//        
//    }
    

    if (image) {
        
        //PS: image variable is the original size image (2448*3264)
        UIImage *onScreenImage = [LoadControls scaleImage:image withScale:2.5f withRect:rect andCropSize:size];
        UIImage *originalImage = [UIImage imageWithCGImage:onScreenImage.CGImage];
        NSMutableArray *localFoods = [NSMutableArray array];
        self.imgArray = [self.textDetector2 findTextArea:originalImage];
        NSLog(@"+++ MAIN VC +++ : text areas %d",(int)self.imgArray.count);
        if ([_imgArray count] > 0)
        {
            for(UIImage *preImage in _imgArray){
                
                _tempMat= [preImage CVMat];
                
                // Step 3. put Mat into pre processor- Charlie
                _tempMat = [self.ipp processImage:_tempMat];
                NSString *ocrStr = [self recognizeImageWithTesseract:[UIImage imageWithCVMat:_tempMat]];
                NSLog(@" ++++++++++ MAIN VC +++++++++++ : TEESSACT REC: %@",ocrStr);
                
                
                NSArray *returnResultsFromDB = [dict localSearchOCRString:ocrStr];
                
                if(returnResultsFromDB){
                    
                    [localFoods addObjectsFromArray:returnResultsFromDB];
                    
                    //hao added
                    [self.camView stopLoadingAnimation];
                    
                    [self showResultButtonsAndCollectionView];
                    
                    [self addFoodItems:localFoods];
                    
                }
            }
            
            if(localFoods.count == 0){
                //can't search anything from DB
                [self stopAnimationAndShowErrorToast];
            }
        }else{
            //can't detect anything from textDetector
            [self stopAnimationAndShowErrorToast];
        }
    }

    NSLog(@"******************!! !! PHOTO TAKEN  !! !!********************");
}

-(void)stopAnimationAndShowErrorToast{
    //no image coming back, tell users to retake
    [self.camView stopLoadingAnimation];
    
    [self.camView backBtnPressed:nil];
    
    self.counterForNoResult++;

    if(self.counterForNoResult>1){
        self.counterForNoResult = 0;
        [self.view makeToast:AMLocalizedString(@"NICE_WARNING_CONTEXT", nil)
                    duration:7.0
                    position:@"top"
                       title:AMLocalizedString(@"NICE_WARNING_TITLE", nil)
                       image:[UIImage imageNamed:@"indicate_1.jpg"]];
    }

    [self.view makeToast_ForCamera:AMLocalizedString(@"DETECTOR_NO_RESULT", nil)];
}

-(void)showResultButtonsAndCollectionView{
    
    self.counterForNoResult = 0;
    
    if(self.collectionView.isHidden){
        self.collectionView.hidden = NO;
        self.collectionView.alpha = 1;
        
        [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.clearBtn.alpha = 1;
            self.nextBtn.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                self.clearBtn.hidden = NO;
                self.nextBtn.hidden = NO;
            }
        }];
    }
}

-(void)hideResultButtonsAndCollectionView{
    if(!self.collectionView.isHidden){
        [UICollectionView transitionWithView:self.collectionView
                                    duration:0.5
                                     options:UIViewAnimationOptionTransitionCrossDissolve
                                  animations:^(){
                                      //alpha collection view and two buttons
                                      self.collectionView.alpha = 0;
                                      self.clearBtn.alpha = 0;
                                      self.nextBtn.alpha = 0;
                                  }
                                  completion:^(BOOL finished){
                                      //hide collection view and two buttons
                                      self.clearBtn.hidden = YES;
                                      self.nextBtn.hidden = YES;
                                      self.collectionView.hidden = YES;
                                  }];
    }
}

//View did load in SimpleCam VC
- (void) EdibleCameraDidLoadCameraIntoView:(MainViewController *)simpleCam {
    NSLog(@"Camera loaded ... ");
    
    
    //pop up introduction view
    
}

- (void)showIntroWithCrossDissolve {
    
    NSString *sampleDescription1 = @"aa";
    NSString *sampleDescription2 = @"bb";
    NSString *sampleDescription3 = @"cc";
    NSString *sampleDescription4 = @"dd";
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello world";
    page1.desc = sampleDescription1;
    page1.bgImage = [UIImage imageNamed:@"bg1"];
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title1"]];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"This is page 2";
    page2.desc = sampleDescription2;
    page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title2"]];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"This is page 3";
    page3.desc = sampleDescription3;
    page3.bgImage = [UIImage imageNamed:@"bg3"];
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title3"]];
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.title = @"This is page 4";
    page4.desc = sampleDescription4;
    page4.bgImage = [UIImage imageNamed:@"bg4"];
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title4"]];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4]];
    [intro setDelegate:self];
    
    [intro showInView:self.view animateDuration:0.3];
}

//introduction view delegate
- (void)introDidFinish:(EAIntroView *)introView {
    NSLog(@"*************** introDidFinish callback ***************");
    HintView *hv = [[HintView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:hv];
    [hv updateSpotLightWithPoint:CGPointMake(300, 189)];

}

// GETTERs
-(ImagePreProcessor*)ipp{
    if(!_ipp){
        _ipp = [[ImagePreProcessor alloc] init];
    }
    return  _ipp;
}

-(NSArray*) imgArray{
    if(!_imgArray){
        _imgArray = [[NSMutableArray alloc] init];
    }
    return  _imgArray;
}

-(NSMutableArray *)foodArray{
    if (!_foodArray) {
        _foodArray = [[NSMutableArray alloc]init];
    }
    return _foodArray;
}

-(NSDictionary *)existingFood{
    if (!_existingFood) {
        _existingFood = [[NSMutableDictionary alloc]init];
    }
    return _existingFood;
}

@end
