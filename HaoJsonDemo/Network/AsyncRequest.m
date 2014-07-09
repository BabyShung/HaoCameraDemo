//
//  LoginRegister.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/15/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "AsyncRequest.h"
#import "ShareData.h"
#import "User.h"
#import "edi_md5.h"

//Test url
//http://edibleserver-env.elasticbeanstalk.com/food?title=Bacon&lang=CN
//http://default-environment-9hfbefpjmu.elasticbeanstalk.com/review?fid=1&uid=10&start=0&offset=5DESC


#define OTHER @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/Other?name=我"

#define FOODURL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/food?"

#define REVIEWURL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/review?"

#define DOREVIEW @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/review"

#define USERURL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/user"

#define FEEDBACKURL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/feedback"

#define FOOD_POST_URL @"http://default-environment-9hfbefpjmu.elasticbeanstalk.com/food"

@interface AsyncRequest ()

@property (strong,nonatomic) id selfy;

@end

@implementation AsyncRequest


-(instancetype)initWithDelegate:(id)selfy{
    
    if (self = [super init]) {
        self.selfy = selfy;
    }
    return self;
}

-(void)getReviews_fid:(NSUInteger)fid{
    [self getReviews_fid:fid withLoadSize:5 andSkip:0];
}

-(void)getReviews_fid:(NSUInteger)fid withLoadSize:(NSUInteger)size andSkip:(NSUInteger)skip{
    
    User *user = [User sharedInstance];

    NSMutableString *paraString = [NSMutableString string];
    [paraString appendString:[NSString stringWithFormat:@"fid=%d&uid=%d&start=%ld&offset=%ld",(int)fid,(int)user.Uid,(long)skip,(long)size]];
    NSMutableString *reviewString =  [NSMutableString stringWithString:REVIEWURL];
    
    [reviewString appendString:paraString];
    
    [self performGETAsyncTaskwithURLString:[NSString stringWithString:reviewString]];
    
}

-(void)getReviews_fid:(NSUInteger)fid byUid:(NSUInteger)uid
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:fid], @"fid",[NSNumber numberWithInteger:uid], @"uid",@"my_review",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:DOREVIEW];
    
    [self performAsyncTask_Dictionary:dict andURL:url];
}

-(void)getFoodInfo:(NSString*)foodname andLang:(TargetLang)lang {
    NSString *language;
    switch (lang) {
        case Chinese:
            language = @"CN";
            break;
        case English:
            language = @"EN";
            break;
        default:
            language = @"CN";
            break;
    }
    
    NSMutableString *paraString = [NSMutableString stringWithString:@"title="];
    [paraString appendString:foodname];
    [paraString appendString:@"&lang="];
    [paraString appendString:language];
    NSMutableString *foodString =  [NSMutableString stringWithString:FOODURL];
    
    [foodString appendString:paraString];
    
    NSString *finalString = [NSString stringWithString:foodString];
    
    
    
    [self performGETAsyncTaskwithURLString:finalString];
    
    
}

//-(void)getFoodInfo:(NSString*)foodname andLanguage:(NSString *)language {
//    
//    NSMutableString *paraString = [NSMutableString stringWithString:@"title="];
//    [paraString appendString:foodname];
//    [paraString appendString:@"&lang="];
//    [paraString appendString:language];
//    NSMutableString *foodString =  [NSMutableString stringWithString:FOODURL];
//    
//    [foodString appendString:paraString];
//    
//    NSString *finalString = [NSString stringWithString:foodString];
//    
//    [self performGETAsyncTaskwithURLString:finalString];
//}

-(void)getFoodInfo_byPost:(NSString*)foodname andLanguage:(TargetLang)lang{
    NSString *language;
    switch (lang) {
        case Chinese:
            language = @"CN";
            break;
        case English:
            language = @"EN";
            break;
        default:
            language = @"CN";
            break;
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:foodname, @"title",language, @"lang", @"search",@"action", nil];
    NSURL *url = [NSURL URLWithString:FOOD_POST_URL];
    [self performAsyncTask_Dictionary:dict andURL:url];
}


/******************
 
 post review
 
 ******************/

-(void)doComment:(Comment *)comment{
    NSNumber *uidNumber = [NSNumber numberWithInteger:[User sharedInstance].Uid];

    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:comment.fid], @"fid",comment.text, @"comments", [NSNumber numberWithInteger:comment.rate], @"rate", uidNumber, @"uid",@"post_update_review",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:DOREVIEW];

    [self performAsyncTask_Dictionary:dict andURL:url];
}

//-(void)doComment:(Comment *)comment rating:(NSUInteger)rate withAction:(NSString*)action {
//    
//    User *user = [User sharedInstance];
//    
//    NSNumber *uidNumber = [NSNumber numberWithInteger:user.Uid];
//    NSNumber *rateNumber = [NSNumber numberWithInteger:rate];
//    
//    
//    NSDictionary * dict;
//    
//    //doing a post action
//    if([action isEqualToString:@"add"]){
//        
//        NSNumber *fidNumber = [NSNumber numberWithInteger:comment.fid];
//        //NSNumber *timeNumber = [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]*1000.0];
//        //NSLog(@"nsnumber %@",timeNumber);
//        
//        dict = [NSDictionary dictionaryWithObjectsAndKeys:fidNumber, @"fid",comment.text, @"comments", rateNumber, @"rate", uidNumber, @"uid",action,@"action", nil];
//        
//        
//    }else{//doing an update action
//        
//        NSNumber *cidNumber = [NSNumber numberWithInteger:comment.cid];
//        
//        
//        dict = [NSDictionary dictionaryWithObjectsAndKeys:cidNumber, @"rid",comment.text, @"comments", rateNumber, @"rate", uidNumber, @"uid", action,@"action", nil];
//        
//    }
//    
//    
//    NSURL *url = [NSURL URLWithString:DOREVIEW];
//     NSLog(@"POST: %@",url);
//    [self performAsyncTask_Dictionary:dict andURL:url];
//}


-(void)sendFeedbackWithContent:(NSString *)content{
    
    User *user = [User sharedInstance];
    NSNumber *uidnumber = [NSNumber numberWithInteger:1];//user.Uid
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:uidnumber, @"uid",content, @"content",@"post_feed_back",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:FEEDBACKURL];
    [self performAsyncTask_Dictionary:dict andURL:url];
}

/******************
 
 like or dislike
 
 ******************/

-(void)likeOrDislike_rid:(int)rid andLike:(int)like {
    
    NSNumber *ridNumber = [NSNumber numberWithInt:rid];
    NSNumber *likeNumber = [NSNumber numberWithInt:like];
    
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:ridNumber, @"rid",likeNumber, @"like",@"like_review",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:DOREVIEW];
    
    [self performAsyncTask_Dictionary:dict andURL:url];
}

/************************
 
 register (post)
 
 ************************/
-(void)signup_withEmail:(NSString*)email andName:(NSString*)name andPwd:(NSString *)pwd {
    //use md5 here
    edi_md5 *edimd5 = [[edi_md5 alloc]init];
    pwd = [edimd5 md5:pwd];
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email",name, @"name",pwd,@"pwd",@"register",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:USERURL];
    //post
    [self performAsyncTask_Dictionary:dict andURL:url];
    
}

/************************
 
 login (post)
 
 ************************/
-(void)login_withEmail:(NSString*)email andPwd:(NSString *)pwd {
    //use md5 here
    edi_md5 *edimd5 = [[edi_md5 alloc]init];
    pwd = [edimd5 md5:pwd];
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email",pwd,@"pwd",@"login",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:USERURL];
   
    //post
    [self performAsyncTask_Dictionary:dict andURL:url];
}

-(void)checkEmail:(NSString*)email {
    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:email, @"email",@"check",@"action", nil];
    
    NSURL *url = [NSURL URLWithString:USERURL];
    //post
    [self performAsyncTask_Dictionary:dict andURL:url];
}


/************************
 
 Shared method (get)
 
 ************************/
-(void)performGETAsyncTaskwithURLString:(NSString *)urlString{
    
    NSString *urlEncodeString =[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"GET summary: %@",urlEncodeString);
    
    NSURL *url = [NSURL URLWithString:urlEncodeString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:_selfy];
    [conn start];
}


/************************
 
 Shared method (post)
 
 ************************/
-(void)performAsyncTask_Dictionary:(NSDictionary *)dict andURL:(NSURL *)url{
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
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:_selfy];
    [conn start];
}



@end