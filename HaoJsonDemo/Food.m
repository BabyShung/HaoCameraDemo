//
//  Food.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Food.h"
//#import ""

const NSString *title = @"Title";
const NSString *translation = @"Translation";
const NSString *description = @"Decription";
const NSString *tags = @"Tags";
const NSString *photos = @"Photos";
const NSString *comments = @"Comments";

@interface Food()
@property (strong,nonatomic) NSMutableData *webdata;
@end
@implementation Food

-(instancetype)initWithTitle:(NSString *)title andTranslations:(NSString *)translate
{
    self = [super init];
    
    self.title = title;
    self.transTitle = translate;
    _webdata = [[NSMutableData alloc]init];
    return self;
}


-(NSString *)description
{
    NSString *desc  = [NSString stringWithFormat:@"Title: %@, transTitle: %@", self.title, self.transTitle];
	return desc;
}

-(void) fetchCommentsCompletion:(void (^)(NSError *err, BOOL sucess))block
{
    
}

-(void) throwFoodExceptionCausedBy:(NSString *)reason{
    
    NSException* ex = [[NSException alloc]initWithName:@"FoodFailures" reason:reason userInfo:nil];
    @throw ex;
    
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
