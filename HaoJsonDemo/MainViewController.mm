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
#import "TextDetector.h"
#import "WordCorrector.h"

#import "Dictionary.h"
#import "Food.h"

#import "LoadControls.h"
#import "AppDelegate.h"

static NSString *CellIdentifier = @"Cell";

@interface MainViewController () <TransitionControllerDelegate,EdibleCameraDelegate>
{
    CGFloat ScreenWidth;
    CGFloat ScreenHeight;
}


@property (strong,nonatomic) Tesseract *tesseract;

@property (strong,nonatomic) NSMutableArray *imgArray;

@property (strong,nonatomic) ImagePreProcessor *ipp;

@property (nonatomic) cv::Mat tempMat;


@property (nonatomic,strong) debugView *debugV;

@property (strong,nonatomic) NSMutableArray *foodArray;

@property (nonatomic, assign) NSInteger cellCount;

@property (strong,nonatomic) TransitionController *transitionController;



@end

@implementation MainViewController

-(NSMutableArray *)foodArray{
    if (!_foodArray) {
        _foodArray = [[NSMutableArray alloc]init];
        
    }
    return _foodArray;
}

- (void)viewDidLoad{
    
    ScreenWidth = CGRectGetWidth([[UIScreen mainScreen] bounds]);
    ScreenHeight = CGRectGetHeight([[UIScreen mainScreen] bounds]);
    
    //number of cell
    self.cellCount = 10;
    
    //setup tesseract
    [self loadTesseract];
    
    //init controls
    [self loadControls];
    

    /*REQUIRED FOR DEBUGGING ANIMATION*/

    self.collectionView.hidden = YES;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //registering dequueue cell
    [self.collectionView registerClass:[EDCollectionCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    
    //self.debugV = [[debugView alloc] initWithFrame:CGRectMake(0, 0, 320, 200) andReferenceCV:self];
    //[self.view insertSubview:self.debugV aboveSubview:self.collectionView];
    
    self.transitionController = [[TransitionController alloc] initWithCollectionView:self.collectionView];
    self.transitionController.delegate = self;
    self.navigationController.delegate = self.transitionController;

}

-(void)loadControls{
    self.camView = [[CameraView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight) andOrientation:self.interfaceOrientation andAppliedVC:self];
    [self.view insertSubview:self.camView belowSubview:self.collectionView];
}


- (void) viewDidAppear:(BOOL)animated {

    
    //set camView delegate to be DEBUG_VC
    [self.Maindelegate setCamDelegateFromMain:self];
    
    
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
    
    cell.backgroundColor = [UIColor whiteColor];
    
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //deselect !!??
    //[collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    
    
    SecondViewController *viewController = [[SecondViewController alloc] initWithCollectionViewLayout:[[largeLayout alloc] init]];
    //used for pausing camera
    viewController.camView = self.camView;
    
    
    viewController.useLayoutToLayoutNavigationTransitions = YES;
    [self.navigationController pushViewController:viewController animated:YES];
}


//delegate method, after calling startInteractiveTransition, will call this
- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView
                        transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    TransitionLayout *transitionLayout = [[TransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

/*----------- ------------*/
-(void)addItem
{
    [self.collectionView performBatchUpdates:^{
        self.cellCount = self.cellCount + 1;
        [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:0]]];
        
    } completion:nil];
}

-(void)addFoodItems:(NSArray *) newFoodItems
{
    if (newFoodItems.count>0) {
        
        
        NSInteger startIndex = self.foodArray.count;
        
        NSMutableArray *newIndexPaths = [[NSMutableArray alloc]init];
        for (int i =0; i<newFoodItems.count; i++){
            [newIndexPaths addObject:[NSIndexPath indexPathForItem:(startIndex+i) inSection:0]];
        }
        [self.collectionView performBatchUpdates:^{
            [self.foodArray addObjectsFromArray:newFoodItems];
            [self.collectionView insertItemsAtIndexPaths:newIndexPaths];
            
        } completion:nil];
    }
}


//transitionVC delegate
- (void)interactionBeganAtPoint:(CGPoint)point
{
    UIViewController *topVC = [self.navigationController topViewController];
    if ([topVC class] != [MainViewController class]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)loadTesseract{
    self.tesseract = [[Tesseract alloc] initWithLanguage:@"eng"];
    [self.tesseract setVariableValue:@"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz" forKey:@"tessedit_char_whitelist"];
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
    self.collectionView.hidden = NO;
    NSArray *localFoods;
    Dictionary *dict = [[Dictionary alloc]initDictInDefaultLang];
    //for (NSString *inputStr in resultStrings)
    //{
    localFoods = [dict localSearchOCRString:@"yeast bread with Worcestershire sauce and yogurt"];
    NSLog(@"Local Foods: %d",(int)localFoods.count);
    [self addFoodItems:localFoods];
    
    if (image) {
        
        
        //PS: image variable is the original size image (2448*3264)
        UIImage *onScreenImage = [LoadControls scaleImage:image withScale:1.5f withRect:rect andCropSize:size];
        UIImage *originalImage = [UIImage imageWithCGImage:onScreenImage.CGImage];
        
        self.imgArray = [TextDetector detectTextRegions:originalImage];

        if ([_imgArray count] > 0)
        {
            for(int i = 0; i<(self.imgArray.count-1);i++){

                _tempMat= [self.imgArray[i] CVMat];
                
                // Step 3. put Mat into pre processor- Charlie
                _tempMat = [self.ipp processImage:_tempMat];
                
                self.imgArray[i] = [UIImage imageWithCVMat:_tempMat];//convert back to uiimage
                
            }
            
            NSString *result = @"";

            for (int i = 0; i<_imgArray.count-1; i++) {
<<<<<<< HEAD
=======

>>>>>>> FETCH_HEAD
                NSString *tmp = [self recognizeImageWithTesseract:[_imgArray objectAtIndex:i]];
                result = [result stringByAppendingFormat:@"%d. %@\n",i, tmp];
                //            NSLog(@"tmp %d: %@",i, tmp);
            }

            
            onScreenImage = [_imgArray objectAtIndex:(_imgArray.count-1)];
            NSLog(@"<<<<<<<<<<1.5 RESULT: \n%@", result);

                /*     Analyze OCR Results locally      */
            NSArray *localFoods;
            Dictionary *dict = [[Dictionary alloc]initDictInDefaultLang];
            //for (NSString *inputStr in resultStrings)
            //{
                localFoods = [dict localSearchOCRString:@"yeast bread with Worcestershire sauce and yogurt"];
                NSLog(@"main view return foods %d",(int)localFoods.count);
            for (Food *localFood in localFoods) {
                NSLog(@"Food : %@ -> %@ ",localFood.title,localFood.transTitle);
            }
            
            //}
            NSLog(@"main view return foods %d",(int)localFoods.count);

        }
        
    }
    
    NSLog(@"******************!! !! PHOTO TAKEN  !! !!********************");
}

//View did load in SimpleCam VC
- (void) EdibleCameraDidLoadCameraIntoView:(MainViewController *)simpleCam {
    NSLog(@"Camera loaded ... ");
    
}

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
@end
