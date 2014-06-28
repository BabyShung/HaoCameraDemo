//
//  ViewController.m
//  HaoTestGetRequest
//
//  Created by Hao Zheng on 6/10/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "NetworkTestViewController.h"
#import "AsyncRequest.h"
#import "Review.h"
#import "GeneralUser.h"
#import "Edible_S3.h"
@interface NetworkTestViewController () <NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong,nonatomic) NSMutableData *webdata;

@end

@implementation NetworkTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _webdata = [[NSMutableData alloc]init];
    
}
- (IBAction)getImage:(id)sender {
    
    Edible_S3 *s3 = [[Edible_S3 alloc]init];
    //fetch an image from the S3 server
    self.imageView.image = [s3 getImageFromS3:@"test_photo.png"];
    
}

- (IBAction)getRequest:(id)sender {
    
    AsyncRequest *async = [[AsyncRequest alloc]init];
    
    [async performGETAsyncTask:self andURLString:@"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/Other?name=我"];
    
    //1.
    //[async getFoodInfo:@"blue cheese" andLanguage:@"CN" andSELF:self];
    
    //2.
    //[async getReviews:@"calico bean" andUid:1 andStart:0 andOffset:5 andSELF:self];
    
    //3.
    
//    GeneralUser *guser = [[GeneralUser alloc]init];
//    guser.Uid = 1;
//    guser.Uname = @"Anonymity";
//    
//    Review *review = [[Review alloc]init];
//    review.title = @"calico bean";
//    review.rate = 5;
//    review.comment = @"Nice food!!!";
//    review.byUser = guser;
//    review.time = [[NSDate date] timeIntervalSince1970]*1000.0;
//    
//    [async doReview:review andAction:@"update" andSELF:self];//action: update, post
    
    
    //4. pass >0 like, pass <0 dislike, pass 0 not change
    //[async likeOrDislike_rid:5 andLike:20 andSELF:self];
    
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

    //1.get food info
//    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];
//    
//    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
//    NSLog(@"status --- -- -   %d",status);
//    
//    if(status){
//        NSMutableArray *results = [returnJSONtoNSdict objectForKey:@"results"];
//        
//        for(NSDictionary *dict in results){
//            NSString *title = [dict objectForKey:@"title"];
//            NSString *description = [dict objectForKey:@"description"];
//            NSLog(@"title --- -- -   %@",title);
//            NSLog(@"description --- -- -   %@",description);
//        }
//    }else{
//        NSLog(@"failed");
//    }
    
    
    
    
    
    
    //2.get reviews
//    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];
//    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
//    NSLog(@"status! --- -- -   %d",status);
//    
//    NSMutableArray *results = [returnJSONtoNSdict objectForKey:@"result"];
//    NSLog(@"count~~: %d",results.count);
//    
//    NSString *title = [[results objectAtIndex:0] objectForKey:@"title"];
//    NSLog(@"title --- -- -   %@",title);
//    
//    NSDictionary *user = [[results objectAtIndex:0] objectForKey:@"user"];
//    NSString *uid = [user objectForKey:@"uid"];
//    NSLog(@"uid --- -- -   %@",uid);
    
    
    
    //3.post review
    
//    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];
//    
//    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
//    NSLog(@"Output: %@",tmp);
//    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
//    NSLog(@"status! --- -- -   %d",status);

    

    //4.like review
    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    NSLog(@"!?? %@",tmp);
}




@end
