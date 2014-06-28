//
//  LoginRegister.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AsyncRequest.h"
#import "User.h"


//Test url
//http://edibleserver-env.elasticbeanstalk.com/food?title=Bacon&lang=CN
//http://edibleserver-env.elasticbeanstalk.com/review?title=bacon&start=0&offset=5&order=LIKE_NUM DESC


#define OTHER @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/Other?name=我"

#define FOODURL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/food?"

#define REVIEWURL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/review?"

#define DOREVIEW @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/review"

@implementation AsyncRequest 

-(void)getReviews_fid:(NSUInteger)fid andSELF:(id)selfy{
    
    User *user = [User sharedInstance];
    
    NSMutableString *paraString = [NSMutableString string];
    [paraString appendString:[NSString stringWithFormat:@"fid=%d&uid=%d&start=0&offset=5",fid,user.Uid]];
    NSMutableString *reviewString =  [NSMutableString stringWithString:REVIEWURL];
    
    [reviewString appendString:paraString];
    
    [self performGETAsyncTask:selfy andURLString:[NSString stringWithString:reviewString]];
}


-(void)getFoodInfo:(NSString*)foodname andLanguage:(NSString *)language andSELF:(id)selfy{

    NSMutableString *paraString = [NSMutableString stringWithString:@"title="];
    [paraString appendString:foodname];
    [paraString appendString:@"&lang="];
    [paraString appendString:language];
    NSMutableString *foodString =  [NSMutableString stringWithString:FOODURL];
    
    [foodString appendString:paraString];

    NSString *finalString = [NSString stringWithString:foodString];
    

    
    [self performGETAsyncTask:selfy andURLString:finalString];
    
    
}

/******************
 
 post review
 
 ******************/
-(void)doComment:(Comment *)comment toFood:(Food *)food withAction:(NSString*)action andSELF:(id)selfy{

    User *user = [User sharedInstance];
    
    NSNumber *uidNumber = [NSNumber numberWithInt:user.Uid];
    NSNumber *rateNumber = [NSNumber numberWithInt:comment.rate];
    
    NSDictionary * dict;
    
    //doing a post action
    if([action isEqualToString:@"add"]){
        
        NSNumber *fidNumber = [NSNumber numberWithInt:food.fid];
        //NSNumber *timeNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000.0];
        //NSLog(@"nsnumber %@",timeNumber);
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys:fidNumber, @"fid",comment.comment, @"comments", rateNumber, @"rate", uidNumber, @"uid",action,@"action", nil];
        
        
    }else{//doing an update action
        
        NSNumber *cidNumber = [NSNumber numberWithInt:comment.cid];
        
        
        dict = [NSDictionary dictionaryWithObjectsAndKeys:cidNumber, @"rid",comment.comment, @"comments", rateNumber, @"rate", uidNumber, @"uid", action,@"action", nil];
        
    }


    NSURL *url = [NSURL URLWithString:DOREVIEW];
    
    [self performAsyncTask:selfy andDictionary:dict andURL:url];
}

/******************
 
 like or dislike
 
 ******************/
-(void)likeOrDislike_rid:(int)rid andLike:(int)like andSELF:(id)selfy{
    
    NSNumber *ridNumber = [NSNumber numberWithInt:rid];
    NSNumber *likeNumber = [NSNumber numberWithInt:like];
    
    

    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:ridNumber, @"rid",likeNumber, @"like",@"like",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:DOREVIEW];
    
    [self performAsyncTask:selfy andDictionary:dict andURL:url];
}


/************************
 
 Shared method (get)
 
 ************************/
-(void)performGETAsyncTask:(id)selfy andURLString:(NSString *)urlString{

    NSString *urlEncodeString =[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"GET summary: %@",urlEncodeString);
    
    NSURL *url = [NSURL URLWithString:urlEncodeString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:selfy];
    [conn start];
}


/************************
 
 Shared method (post)
 
 ************************/
-(void)performAsyncTask:(id)selfy andDictionary:(NSDictionary *)dict andURL:(NSURL *)url{
    NSError *error;
    //convert dictionary to data
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:&error];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:jsonData];
    // print json:
    NSLog(@"JSON summary: %@", [[NSString alloc] initWithData:jsonData
                                                     encoding:NSUTF8StringEncoding]);
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:selfy];
    [conn start];
}



@end
