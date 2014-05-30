//
//  TestViewController.m
//  EdibleCameraApp
//
//  Created by MEI C on 5/30/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "TestViewController.h"
#import "TextDetector.h"

@interface TestViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UIImageView *imgView2;
@property (weak, nonatomic) IBOutlet UIImageView *imgView3;
@property (weak, nonatomic) IBOutlet UIImageView *imgView4;
@property (weak, nonatomic) IBOutlet UIImageView *imgView5;
@property (weak, nonatomic) IBOutlet UIImageView *imgView6;
@property (weak, nonatomic) IBOutlet UIImageView *imgView7;

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UIImage imageNamed:@"w2-1:3.jpg"];
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    NSArray *imgArray = [[NSArray alloc] initWithArray:[TextDetector UIImagesOfTextRegions:[UIImage imageNamed:@"w2-1:3.jpg"] withLocations:locations]];
    self.imgView1.image = [imgArray objectAtIndex:0];
    self.imgView2.image = [imgArray objectAtIndex:1];
    self.imgView3.image = [imgArray objectAtIndex:2];
    self.imgView4.image = [imgArray objectAtIndex:3];
    self.imgView5.image = [imgArray objectAtIndex:4];
    self.imgView6.image = [imgArray objectAtIndex:5];
    self.imgView7.image = [imgArray objectAtIndex:6];
    for (NSValue *tmpVal in locations) {
        CGRect tmprect = [tmpVal CGRectValue];
        NSLog(@"(%f, %f)",tmprect.origin.x, tmprect.origin.y);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
