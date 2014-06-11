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

@interface NetworkTestViewController () <NSURLConnectionDataDelegate>

@property (strong,nonatomic) NSMutableData *webdata;

@end

@implementation NetworkTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    _webdata = [[NSMutableData alloc]init];
    
}

- (IBAction)getRequest:(id)sender {
    

    
    AsyncRequest *async = [[AsyncRequest alloc]init];
    //1.
    //[async getFoodInfo:@"Boston baked beans with pork and beans" andLanguage:@"CN" andSELF:self];
    //2.
    //[async getReviews:@"Bacon" andStart:0 andOffset:5 andSELF:self];
    //3.
    
    GeneralUser *guser = [[GeneralUser alloc]init];
    guser.Uid = @"edible_admin";
    guser.Uname = @"Anonymity";
    
    Review *review = [[Review alloc]init];
    review.title = @"Pork and beans";
    review.rate = 5;
    review.comment = @"Nice food!";
    review.byUser = guser;
    
    [async postReview:review andSELF:self];
    
    
    //4. pass >0 like, pass <0 dislike, pass 0 not change
    //[async likeOrDislike:@"edible_admin" andTitle:@"Bacon" andLikeByUid:@"edible_admin2" andLike:1 andSELF:self];
    
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
//    NSMutableArray *results = [returnJSONtoNSdict objectForKey:@"results"];
//
//    for(NSDictionary *dict in results){
//        NSString *title = [dict objectForKey:@"title"];
//        NSString *description = [dict objectForKey:@"description"];
//        NSLog(@"title --- -- -   %@",title);
//        NSLog(@"description --- -- -   %@",description);
//    }
    
    
    
    
    //2.get reviews
//    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];
//    NSMutableArray *results = [returnJSONtoNSdict objectForKey:@"results"];
//    NSLog(@"count~~: %d",results.count);
//    
//    NSString *title = [[results objectAtIndex:0] objectForKey:@"title"];
//    NSLog(@"title --- -- -   %@",title);
//    
//    NSDictionary *user = [[results objectAtIndex:0] objectForKey:@"user"];
//    NSString *uid = [user objectForKey:@"uid"];
//    NSLog(@"uid --- -- -   %@",uid);
    
    //3.post review
    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    NSLog(@"?? %@",tmp);



    //4.like review
    //NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    //NSLog(@"!?? %@",tmp);
}




@end
