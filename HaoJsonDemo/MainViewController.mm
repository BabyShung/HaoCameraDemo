//
//  MainViewController.h
//  EdibleCameraApp
//
//  Created by Hao Zheng on 5/24/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.

#import "MainViewController.h"
#import "largeLayout.h"
#import "TransitionController.h"
#import "EDCollectionCell.h"
#import "TransitionLayout.h"
#import "SecondViewController.h"
#import "opencv2/opencv.hpp"
#import "UIImage+OpenCV.h"
#import "ImagePreProcessor.h"
#import "TextDetector2.h"
#import "WordCorrector.h"
#import "Dictionary.h"
#import "ED_Color.h"
#import "LoadControls.h"
#import "SearchDictionary.h"
#import "User.h"
#import "UIView+Toast.h"
#import "Flurry.h"
#import "NSUserDefaultControls.h"
#import "introContainer.h"

#import "CameraManager.h"
#import "DNUtils.h"

#define SCALE_FACTOR_IMAGE 2.5f

static NSString *CellIdentifier = @"Cell";

@interface MainViewController () <TransitionControllerDelegate,EdibleCameraDelegate>
{
    CGFloat ScreenWidth;
    CGFloat ScreenHeight;
}
@property (strong, nonatomic) UIButton * clearBtn;
@property (strong, nonatomic) UIButton * nextBtn;
@property (strong, nonatomic) UIButton * rightTopBtn;

@property (strong, nonatomic) UILabel *friendlyResultLabel;

@property (strong,atomic) Tesseract *tesseract;

@property (strong,nonatomic) NSMutableArray *imgArray;
@property (strong,nonatomic) ImagePreProcessor *ipp;
@property (nonatomic) cv::Mat tempMat;

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
        introContainer *ic = [[introContainer alloc] initWithFrame:self.view.bounds];
        ic.shouldShowHint = YES;
        [self.view addSubview:ic];
        [ic showIntroWithCrossDissolve];
    }


}

- (void) clearBtnPressed:(id)sender {
    
    [Flurry logEvent:@"Clear_Btn_Pressed"];  
    
    //save searchHistory and clear
    [SearchDictionary saveSearchHistoryToLocalDB];
    [self.camView backBtnPressed:nil];
    [self.camView resumeCameraWithBlocking];
    
    
    //Clean up cached comments of different foods
    NSLog(@"+++++++ MVC +++++++++ : clean up last comntes");
    [[User sharedInstance].lastComments removeAllObjects];
    
    //MVC components
    [self hideResultButtonsAndCollectionView];

    self.existingFood =nil;
    
    [self.foodArray removeAllObjects];
    [self.collectionView reloadData];
    
    _friendlyResultLabel.text = @"";
}

//right bottom button
- (void) nextBtnPressed:(id)sender {
    [self.camView nextPagePressed:nil];
}

- (void) viewDidAppear:(BOOL)animated {
    
    //[self.camView startLoadingAnimation];
    [self.camView registerFocusListener];
    
    [self bringSubViewsToFront];
    //[self updateFriendlyResultLabel:self.foodArray.count];
    
    if (!self.collectionView.hidden) {
        [self showClearAndNextButton];
    }
    
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
    

//    Dictionary *dict = [[Dictionary alloc]initDictInDefaultLang];
//    NSString* str = @"ribeye caper tomato basil apple potato toufu sushi mushroom blue cheese bacon kale";
//    //@"ribeye caper cilantro chicken flat bread sushi apple potato starch fillet steak";
//    [self addFoodItems:[dict localSearchOCRString:str]];
//    
//    [self showClearAndNextButton];
//    [self showCollectionView];

//    [dict serverSearchOCRString:str inLang:English andCompletion:^(NSArray *results, BOOL success) {
//        [self addFoodItems:results];
//    }];

}

- (void) bringSubViewsToFront
{
    [self.view bringSubviewToFront:_clearBtn];
    [self.view bringSubviewToFront:_nextBtn];
    [self.view bringSubviewToFront:_rightTopBtn];
    [self.view bringSubviewToFront:self.friendlyResultLabel];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    [self.camView unregisterFocusListener];
}

/*******************************
 
 collection view delegate
 
 *****************************/
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.foodArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EDCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    Food *food = [self.foodArray objectAtIndex:indexPath.row];
    
    NSLog(@"+++++++++++++++++ MVC +++++++++++++++++++ : %@ WILL PASS INTO CELL %d",food.title,(int)indexPath.row);
    
    [cell configFIVForCell:indexPath.row withFood: food];
    //NSLog(@"+++++++++++++++++++++++++ MVC +++++++++++++++++++ : CELL %d -- %@ hidden %d",indexPath.row, food.title,cell.foodInfoView.descripView.isHidden);
    if (food.isFoodInfoCompleted == NO && food.isLoadingInfo == NO) {

        [food fetchAsyncInfoCompletion:^(NSError *err, BOOL success){

            if (success) {

                [self.collectionView reloadData];

        
            }
            
        }];
    }
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
        NSMutableArray *newIndexPaths = [[NSMutableArray alloc]init];
        NSMutableArray *addItems = [[NSMutableArray alloc]initWithArray:newFoodItems];
        
        for (int i = addItems.count-1,j = 0; i>= 0; i--){
            Food *food = addItems[i];
            if (![self.existingFood valueForKey:[food.title lowercaseString]]) {
                [self.existingFood setValue:@"1" forKey:[food.title lowercaseString]];
                [newIndexPaths addObject:[NSIndexPath indexPathForItem:j inSection:0]];
                j++;
            }
            else{
                [addItems removeObjectAtIndex:i];
            }
        }
        // added by Yang WAN...
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView performBatchUpdates:^{
                [self.foodArray replaceObjectsInRange:NSMakeRange(0,0) withObjectsFromArray:addItems];
                [self updateFriendlyResultLabel:self.foodArray.count];
                [self.collectionView insertItemsAtIndexPaths:newIndexPaths];
                
            } completion:^(BOOL success){
                [self.collectionView reloadData];
            }];
        }); // end on main thread block
        


    }
}


//-(void)addFoodItems:(NSArray *) newFoodItems
//{
//    if (newFoodItems.count>0) {
//        
//        NSInteger startIndex = self.foodArray.count;
//        
//        NSMutableArray *newIndexPaths = [[NSMutableArray alloc]init];
//        NSMutableArray *addItems = [[NSMutableArray alloc]initWithArray:newFoodItems];
//        
//        int count = (int)addItems.count;
//        for (int i =0; i<count; i++){
//            Food *food = addItems[i];
//            if (![self.existingFood valueForKey:[food.title lowercaseString]]) {
//                [self.existingFood setValue:@"1" forKey:[food.title lowercaseString]];
//                [newIndexPaths addObject:[NSIndexPath indexPathForItem:(startIndex+i) inSection:0]];
//            }
//            else{
//                [addItems removeObjectAtIndex:i];
//                i--;
//                count--;
//            }
//        }
//        
//        [self.collectionView performBatchUpdates:^{
//            [self.foodArray addObjectsFromArray:addItems];
//            [self.collectionView insertItemsAtIndexPaths:newIndexPaths];
//            
//        } completion:^(BOOL finished){
////            //NSLog(@"++++++++++  MVC ++++++++++++: After addinglen = %d",self.foodArray.count);
////            int tmpcount = self.foodArray.count-count;
////            int len = self.foodArray.count;
////            for (int i = tmpcount; i <len; i++) {
////                NSLog(@"+++++++++++++++++++++++++ MVC +++++++++++++++++++ i = %d; array count = %d; count = %d",i,(int)tmpcount,len);
////                Food *food = [self.foodArray objectAtIndex:i];
////                //This food's info is not completed
////                if (food.isFoodInfoCompleted == NO) {
////                    
////                    //This food should fetch details
////                    NSLog(@"+++++++++++++++++++++++++ MVC +++++++++++++++++++ %@ WILL REQUEST details",food.title);
////                    [food fetchAsyncInfoCompletion:^(NSError *err, BOOL success) {
////                        if (success) {
////                            
////                            
////                            //All info is ready, reload collection view
////                            NSLog(@"+++++++++++++++++++++++++ MVC +++++++++++++++++++ %@ Finish loading WIll reload data",food.title);
////                            //[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[self.foodArray indexOfObject:food] inSection:0]];
////                            
////                            
////                        }
////                        
////                    }];
////               }
////            }
//        }];
//    }
//}

//transitionVC delegate
- (void)interactionBeganAtPoint:(CGPoint)point{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadTesseract{
    _tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];//langague package
    [_tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz,.&-@#$)(;:!" forKey:@"tessedit_char_whitelist"]; //limit search
}

#pragma mark --------- Tesseract
//tesseract processing
-(NSString *)recognizeImageWithTesseract:(UIImage *)img{
    [_tesseract setImage:img]; //image to check
    [_tesseract recognize];//processing
    NSString *recognizedText = [_tesseract recognizedText];
    NSLog(@"Tesseract Recognized: %@", recognizedText);
    return recognizedText;
}

#pragma mark CAMERA DELEGATE

- (void) EdibleCamera:(MainViewController *)simpleCam didFinishWithImage:(UIImage *)image withRect:(CGRect)rect andCropSize:(CGSize)size{
    
    NSLog(@"******************!! !! PHOTO TAKEN  !! !!********************");
    
    /****** OCR and Searching Components *****/
    
    Dictionary *dict = [[Dictionary alloc]initDictInDefaultLang];
    
    if (image) {
        
        //PS: image variable is the original size image (2448*3264)
        UIImage *onScreenImage = [LoadControls scaleImage:image withScale:SCALE_FACTOR_IMAGE withRect:rect andCropSize:size];
        UIImage *originalImage = [UIImage imageWithCGImage:onScreenImage.CGImage];
        NSMutableArray *localFoods = [NSMutableArray array];
        NSMutableArray *serverFoods = [NSMutableArray array];
        
        //text detector to return an array of images
        self.imgArray = [self.textDetector2 findTextArea:originalImage];
        NSLog(@"+++ MAIN VC +++ : text areas %d",(int)self.imgArray.count);
        
        //string to be sent to server
        NSMutableString *serverInputStr= [NSMutableString stringWithString:@""];
        
        //for each the region image
        for(UIImage *preImage in _imgArray){
            
            if (![self.camView isFocusRegistered]) { //  || !self.camView.camManager.busyNow, do we need this?! Yang WAN
                return;
            }
            
            _tempMat= [preImage CVMat];
            
            // Step 3. put Mat into pre processor- Charlie
            _tempMat = [self.ipp processImage:_tempMat];
            
            //get the string from Tesseract
            NSString *ocrStr = [self recognizeImageWithTesseract:[UIImage imageWithCVMat:_tempMat]];
            
            NSLog(@" ++++++++++ MAIN VC +++++++++++ : TEESSACT REC: %@",ocrStr);
            
            [serverInputStr appendFormat:@" %@",ocrStr];
            
            NSArray *returnResultsFromDB = [dict localSearchOCRString:ocrStr];
            if(returnResultsFromDB){
                
                [localFoods addObjectsFromArray:returnResultsFromDB];
                
                [self showCollectionView];
                
                [self addFoodItems:localFoods];
                
                //hao added
                [self.camView stopLoadingAnimation];
                
            }
        }
        
        if(self.foodArray.count!=0){
            [self showClearAndNextButton];
            
        }else{
            //self.camView.capturedImageView.image = nil;
        }
        
        //check serverInputStr before sending to server
        NSString *trimmedString = [serverInputStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([trimmedString isEqualToString:@""]) {
            // it's empty or contains only white spaces
            [self stopAnimationAndShowErrorToast];
            
        }else{//can send to server
            
            [dict serverSearchOCRString:serverInputStr inLang:English andCompletion:^(NSArray *results, BOOL success) {
                
                //[NSThread sleepForTimeInterval:2.f];
                
                if (results.count > 0){
                    //stop loading result indicator
                    [self.camView stopLoadingAnimation];
                    
                    NSLog(@"++++++++++++ MVC +++++++++++++ : SERVER RETURNED %d  food results - - - - - - - - - - - - - ",(int)results.count);
                    
                    [self showClearAndNextButton];
                    [self showCollectionView];
                    
                    [serverFoods addObjectsFromArray:results];
                    [self addFoodItems:results];
                    
                    
                }else if(self.foodArray.count == 0){
                    //local and server return nothing
                    
                    //[self hideResultButtonsAndCollectionView];
                    [self stopAnimationAndShowErrorToast];
                    
                    NSLog(@"what .....???!!!");
                }
            }];
        }

    } // end of image check...
    
}


-(void)updateFriendlyResultLabel:(int)number{
    if(number == 0)
        return;
    NSString *showString;
    if(number == 1){
        showString = AMLocalizedString(@"FRIENDLY_RESULT_TEXT_single", nil);
    }else{
        showString = AMLocalizedString(@"FRIENDLY_RESULT_TEXT_plural", nil);
    }
    _friendlyResultLabel.text = [NSString stringWithFormat:@"%d%@",number,showString];
}

-(void)stopAnimationAndShowErrorToast{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //no image coming back, tell users to retake
        [self.camView stopLoadingAnimation];
        
        [self.camView backBtnPressed:nil];
        
        self.counterForNoResult++;
        
        if(self.counterForNoResult>1){
            self.counterForNoResult = 0;
            /*
             // commented by Yang Wan
             // requested by Yi Zhang
            [self.view makeToast:AMLocalizedString(@"NICE_WARNING_CONTEXT", nil)
                        duration:7.0
                        position:@"top"
                           title:AMLocalizedString(@"NICE_WARNING_TITLE", nil)
                           image:[UIImage imageNamed:@"indicate_1.jpg"]];
             */
        }
        
        [self.view makeToast_ForCamera:AMLocalizedString(@"DETECTOR_NO_RESULT", nil)];
    });

}

-(void)showCollectionView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.collectionView.isHidden){
            self.collectionView.hidden = NO;
            self.collectionView.alpha = 1;
            [DNUtils giveMeABorder:self.collectionView withColor:nil];
        }
    }); // end on main thread block

}

-(void)showClearAndNextButton{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self bringSubViewsToFront];
        self.counterForNoResult = 0;
        if(self.clearBtn.isHidden){
            
            [UIView animateWithDuration:.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.clearBtn.alpha = .95;
                self.nextBtn.alpha = .95;
                self.rightTopBtn.alpha = .95;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.clearBtn.hidden = NO;
                    self.nextBtn.hidden = NO;
                    self.rightTopBtn.hidden = NO;
                }
            }];
            
            self.clearBtn.hidden = NO;
            self.nextBtn.hidden = NO;
            self.rightTopBtn.hidden = NO;
        }
    }); // end on main thread block
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
                                      self.rightTopBtn.alpha = 0;
                                  }
                                  completion:^(BOOL finished){
                                      //hide collection view and two buttons
                                      self.clearBtn.hidden = YES;
                                      self.nextBtn.hidden = YES;
                                      self.rightTopBtn.hidden = YES;
                                      self.collectionView.hidden = YES;
                                  }];
    }
}

-(void)loadControls{
    self.camView = [[CameraView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) andOrientation:self.interfaceOrientation andAppliedVC:self];
    [self.view insertSubview:self.camView belowSubview:self.collectionView];
    
    /*REQUIRED FOR DEBUGGING ANIMATION*/
    
    self.collectionView.hidden = YES; // changed by Yang WAN
    self.collectionView.backgroundColor = [UIColor clearColor]; // changed by Yang WAN
    self.collectionView.alpha = 0.5;
    [DNUtils giveMeABorder:self.collectionView withColor:[UIColor blueColor]];
    
    //registering dequueue cell
    [self.collectionView registerClass:[EDCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    
    self.transitionController = [[TransitionController alloc] initWithCollectionView:self.collectionView];
    self.transitionController.delegate = self;
    self.navigationController.delegate = self.transitionController;
    
    
    //add in collectionView
    
    _clearBtn = [LoadControls createRoundedButton_Image:@"go_back.png" andTintColor:[ED_Color redColor] andImageInset:UIEdgeInsetsMake(6, 4, 6, 6) andLeftBottomElseRightBottom:YES];
    [_clearBtn addTarget:self action:@selector(clearBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _clearBtn.hidden = YES;
    [self.view insertSubview:_clearBtn aboveSubview:self.collectionView];
    
    _nextBtn = [LoadControls createRoundedButton_Image:@"CameraNext.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(8, 7, 8, 9) andLeftBottomElseRightBottom:NO];
    [_nextBtn addTarget:self action:@selector(nextBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    _nextBtn.hidden = YES;
    [self.view insertSubview:_nextBtn aboveSubview:self.collectionView];
    
    // these are temporarily left here, by Yang WAN
    // copied from CameraView...
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    CGFloat BUTTON_Starting_MARGIN_LEFT_RIGHT = 30;
    CGFloat halfButtonSize = _clearBtn.bounds.size.width/2;
    CGFloat BUTTON_MARGIN_DOWN = 12;
//    screenHeight - _backBtn.bounds.size.height / 2 - BUTTON_MARGIN_DOWN;
    CGFloat x_center = screenWidth / 2 ;
    CGFloat y_bottom_align = screenHeight - halfButtonSize - BUTTON_MARGIN_DOWN;
    CGPoint rightTopBtnPoint = CGPointMake(x_center, y_bottom_align);
    
    _rightTopBtn = [LoadControls createRoundedButton_Image:@"close-icon.png" andTintColor:[ED_Color edibleBlueColor] andImageInset:UIEdgeInsetsMake(8, 9, 8, 7) andLeftBottomElseRightBottom:NO andStartingPosition:rightTopBtnPoint];
    [_rightTopBtn addTarget:self action:@selector(startOrStopFocusListenerOnCollectionView:) forControlEvents:UIControlEventTouchUpInside];
    _rightTopBtn.hidden = YES;
    [self.view insertSubview:_rightTopBtn aboveSubview:self.collectionView];

    [DNUtils giveMeABorder:_clearBtn withColor:[UIColor blueColor]];
    [DNUtils giveMeABorder:_nextBtn withColor:[UIColor blueColor]];
    [DNUtils giveMeABorder:_rightTopBtn withColor:[UIColor blueColor]];
    
    
    _friendlyResultLabel = [LoadControls createLabelWithRect:CGRectMake(0, 0, 260, 50) andTextAlignment:NSTextAlignmentCenter andFont:[UIFont fontWithName:@"Heiti TC" size:16] andTextColor:[ED_Color edibleBlueColor_doubleBlue]];
    _friendlyResultLabel.text = @"";
    _friendlyResultLabel.center = CGPointMake(160, ScreenHeight - 35 - bottomOffset);
    [self.view addSubview:_friendlyResultLabel];
}

- (void) startOrStopFocusListenerOnCollectionView:(id)sender
{
    if (self.camView) {
        // for collection view's change of image only ...
        if ([self.camView isFocusRegistered]) {
            UIImage *tickImg = [UIImage imageNamed:@"check_black.png"];
            [_rightTopBtn setImage:tickImg forState:UIControlStateNormal];
        }else{
            
            UIImage *tickImg = [UIImage imageNamed:@"close-icon.png"];
            [_rightTopBtn setImage:tickImg forState:UIControlStateNormal];
        }
        
        
        [self.camView startOrStopFocusListener:sender];
        

    }

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
