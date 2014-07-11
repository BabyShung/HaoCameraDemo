//
//  ViewController.m
//  HaoTestGetRequest
//
//  Created by Hao Zheng on 6/10/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "NetworkTestViewController.h"
#import "AsyncRequest.h"
#import "Comment.h"
#import "User.h"
#import "Edible_S3.h"
#import "Food.h"
#import <AWSRuntime/AWSRuntime.h>
@interface NetworkTestViewController () <NSURLConnectionDataDelegate,AmazonServiceRequestDelegate>

{
    NSMutableData *imageData;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) NSMutableData *webdata;


@property (weak, nonatomic) IBOutlet UITextField *textField;


@property (strong,nonatomic) AsyncRequest *async;


@end

@implementation NetworkTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _webdata = [[NSMutableData alloc]init];
    
    self.async = [[AsyncRequest alloc]initWithDelegate:self];
    
}
- (IBAction)getImage:(id)sender {
    
    Edible_S3 *s3 = [[Edible_S3 alloc]init];
    //fetch an image from the S3 server
    //self.imageView.image = [s3 getImageFromS3:@"1_1405107773080.jpg"];
    
    
    [s3 getImageFromS3Async:@"1_1405107773080.jpg"  andSelfy:self];
    
}

/****************************************
 
 delegate methods for networkConnection
 
 ****************************************/


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [_webdata setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_webdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops.." message:[error description]  delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{    //async

    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    NSLog(@"!?? %@",tmp);
}


- (IBAction)getFoodInfo:(id)sender {
    [self.async getFoodInfo:@"oatmeal" andLang:[[ShareData shareData] defaultTargetLang]];
}

- (IBAction)getReview:(id)sender {
    
    [self.async getReviews_fid:1];
}

- (IBAction)postReview:(id)sender {
    
    //user,late will move to login
    //[User sharedInstanceWithUid:7 andEmail:@"gcte2010@gmail.com" andUname:@"Charlie" andUpwd:@"engineer" andUtype:1 andUselfie:nil];
    [User loginWithEmail:@"gcte2010@gmail.com" andPwd:@"engineer" andCompletion:^(NSError *err, BOOL success) {
        if (success) {
            //Comment *review = [[Comment alloc]initWithCommentID:0 andFid:2 andRate:3 andComment:@"ggrd"];
            //
            //
            //    [self.async doComment:review rating:3 withAction:@"add"];//action: update, post
            //[self.async doComment:review];
            [User fetchMyCommentOnFood:2 andCompletion:nil];
        }
    }];
//
//    //commen
//    [self.async getReviews_fid:2 byUid:1];
    

}

- (IBAction)updateReview:(id)sender {
    
    //user,late will move to login
    [User sharedInstanceWithUid:2 andEmail:@"123@.com" andUname:@"Anonymity" andUpwd:@"123" andUtype:1 andUselfie:nil];

    
    //comment
    Comment *review = [[Comment alloc]initWithCommentID:8 andFid:1 andRate:3 andComment:@"User Hao commented*******"];
    
    [self.async doComment:review];
    //[self.async doComment:review rating:3 withAction:@"update"];//action: update, post
}

- (IBAction)like:(id)sender {
    
    [self.async likeOrDislike_rid:1 andLike:20];
    
}
- (IBAction)testBlock:(id)sender {
    
    Food *food = [[Food alloc]initWithTitle:@"sushi" andTranslations:@"寿司"];
    food.fid = 1;//for fetch comment
    
    [food fetchAsyncInfoCompletion:^(NSError *err, BOOL success){
        NSLog(@"%d",success);
        NSLog(@"fetch food info block!");
    }];
    
    [food fetchOldestCommentsSize:5 andSkip:0 completion:^(NSError *err, BOOL success){
        NSLog(@"%d",success);
        NSLog(@"fetch comment block!");
    }];
}

- (IBAction)login:(id)sender {
    
    [self.async login_withEmail:@"1xxx@123.com" andPwd:@"123"];
}

- (IBAction)signup:(id)sender {
    
    [self.async signup_withEmail:@"1xxx@123.com" andName:@"hao" andPwd:@"123"];
}

- (IBAction)checkEmail:(id)sender {
    [self.async checkEmail:@"hao4@123.com"];
}

- (IBAction)sendFeedback:(id)sender {
    
    NSString *content = @"A lof of bugs!";
    [self.async sendFeedbackWithContent:content];
    
}

/************************
 
 Amazon delegate
 
 **********************/
-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response{
    //Setup to collect image data
    NSLog(@"************** S3 ********************************************** S3 ******** didReceiveResponse");
    imageData = [NSMutableData data];
}

-(void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data{

    [imageData appendData:data];
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
     UIImage *image = [UIImage imageWithData:imageData];
    self.imageView.image = image;
    
    
     NSLog(@"************** S3 ********************************************** S3 ********222");
 
}



-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{

    NSLog(@"Amazon failed To Load Image: %@", error.localizedDescription);

}


@end
