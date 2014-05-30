//
//  EP_thirdViewController.m
//  PageViewDemo
//
//  Created by Hao Zheng on 5/23/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "EP_thirdViewController.h"
#import "LoadControls.h"


@interface EP_thirdViewController ()

@property (strong, nonatomic) NSArray* imgArray;


@end

@implementation EP_thirdViewController

-(NSArray*) imgArray{
    if(!_imgArray){
        _imgArray = [[NSArray alloc] init];
    }
    return  _imgArray;
}


//
-(void)getAllDetectedImages:(NSArray *)imageArray{
    
    [[self.view subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.imgArray = imageArray;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
}


-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"view will appear");
    
//    LoadControls *lc = [[LoadControls alloc]init];
//    UIImageView *iv = [lc createImageViewWithRect:CGRectMake(10, 10, 100, 100)];
//    iv.image = [UIImage imageNamed:@"shutter@2x.png"];
//    [self.view addSubview:iv];
    
    
    if(self.imgArray.count != 0){
        
        LoadControls *lc = [[LoadControls alloc]init];
        
        CGFloat x =10;
        CGFloat y = 30;
        for(int i = 0 ; i<self.imgArray.count - 1;i++){
            
            UIImage *img = self.imgArray[i];
            UIImageView *tmpView= [lc createImageViewWithRect:CGRectMake(x, y, img.size.width/1.5, img.size.height/1.5)];
            tmpView.image = img;
            [self.view addSubview:tmpView];
            y += img.size.height + 5;
        }
    }
    
    
}


-(void)viewDidAppear:(BOOL)animated{
    [self.delegate checkTabbarStatus:self.pageIndex];

}


@end
