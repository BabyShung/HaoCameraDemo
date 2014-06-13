//
//  LoginRegister.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AsyncRequest.h"

//Test url
//http://edibleserver-env.elasticbeanstalk.com/food?title=Bacon&lang=CN
//http://edibleserver-env.elasticbeanstalk.com/review?title=bacon&start=0&offset=5&order=LIKE_NUM DESC


#define FOODURL @"http://edibleserver-env.elasticbeanstalk.com/food?"
#define REVIEWURL @"http://edibleserver-env.elasticbeanstalk.com/review?"

#define POSTREVIEW @"http://edibleserver-env.elasticbeanstalk.com/postreview"
#define LIKEREVIEW @"http://edibleserver-env.elasticbeanstalk.com/likereview"
@implementation AsyncRequest 

-(void)getReviews:(NSString*)foodname andStart:(NSUInteger)start andOffset:(NSUInteger)offset andSELF:(id)selfy{
    
    NSMutableString *paraString = [NSMutableString stringWithString:@"title="];
    [paraString appendString:foodname];
    [paraString appendString:[NSString stringWithFormat:@"&start=%d&offset=%d",start,offset]];
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
-(void)postReview:(Review *)review andSELF:(id)selfy{

    NSDictionary * userDict = [NSDictionary dictionaryWithObjectsAndKeys:review.byUser.Uid, @"uid",review.byUser.Uname, @"uname", nil];

    NSString *rate = [NSString stringWithFormat:@"%lu", (unsigned long)review.rate];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:review.title, @"title",review.comment, @"comments", rate, @"rate", userDict, @"user", nil];

    NSURL *url = [NSURL URLWithString:POSTREVIEW];
    
    [self performAsyncTask:selfy andDictionary:dict andURL:url];
}

/******************
 
 like or dislike
 
 ******************/
-(void)likeOrDislike:(NSString *)post_uid andTitle:(NSString *)post_title andLikeByUid:(NSString*)like_uid andLike:(NSInteger)like andSELF:(id)selfy{
    
    NSLog(@"like int: %d",like);

    NSString *like_string = [NSString stringWithFormat:@"%d",like];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:post_uid, @"uid",post_title, @"title", like_uid, @"likedby", like_string, @"like", nil];
    
    NSURL *url = [NSURL URLWithString:LIKEREVIEW];
    
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
