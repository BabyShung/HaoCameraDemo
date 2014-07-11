//
//  Food.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Food.h"
#import "AsyncRequest.h"
#import "Comment.h"
#import "OtherUser.h"
#import "User.h"

const NSString *title = @"Title";
const NSString *translation = @"Translation";
const NSString *description = @"Decription";
const NSString *tags = @"Tags";
const NSString *photos = @"Photos";
const NSString *comments = @"Comments";

typedef void (^edibleBlock)(NSError *err, BOOL success);

@interface Food()

@property (nonatomic,readwrite,getter = isFoodInfoCompleted) BOOL foodInfoComplete;
@property (nonatomic,readwrite,getter = isLoadingInfo) BOOL loadingFoodInfo;
@property (nonatomic,readwrite,getter = isCommentLoaded) BOOL commentLoaded;
@property (nonatomic,readwrite,getter = isLoadingComments) BOOL loadingComments;

@property (nonatomic,strong) AsyncRequest *async;
@property (strong,nonatomic) NSMutableData *webdata;
@property (nonatomic, copy) edibleBlock foodInfoCompletionBlock;
@property (nonatomic, copy) edibleBlock commentCompletionBlock;
@end

@implementation Food

//Local search use this to init Food
-(instancetype)initWithTitle:(NSString *)title andTranslations:(NSString *)translate
{
    if (self = [super init]) {
        self.loadingFoodInfo = NO;
        self.foodInfoComplete = NO;
        self.loadingComments = NO;
        self.commentLoaded = NO;
        
        self.title = [title capitalizedString] ;
        self.transTitle = translate;
        self.food_description = @"";
        _webdata = [[NSMutableData alloc]init];
        _async = [[AsyncRequest alloc]initWithDelegate:self];
        _photoNames = [NSMutableArray array];
        _tagNames = [NSMutableArray array];
        _comments = [NSMutableArray array];
    }
    return self;
}

-(instancetype) initWithTitle:(NSString *)title andTranslations:(NSString *)translate andQueryTimes:(NSUInteger)queryTimes{
    self = [self initWithTitle:title andTranslations:translate];
    self.queryTimes = queryTimes;
    return self;
}

-(instancetype) initWithDictionary:(NSDictionary *) dict{
    self = [super init];
    
    self.loadingFoodInfo = NO;
    self.foodInfoComplete = YES;
    self.loadingComments = NO;
    self.commentLoaded = NO;
    _photoNames = [NSMutableArray array];
    _tagNames = [NSMutableArray array];
    _comments = [NSMutableArray array];
    
    self.fid = [[dict objectForKey:@"fid"] intValue];
    self.title = [[dict objectForKey:@"title"] capitalizedString];
    self.transTitle = [dict objectForKey:@"name"];
    self.food_description = [dict objectForKey:@"description"];
    self.rate = [[dict objectForKey:@"rate"] floatValue];
    _webdata = [[NSMutableData alloc]init];
    _async = [[AsyncRequest alloc]initWithDelegate:self];
    
    NSString *rawTagNams = [dict objectForKey:@"tags"];
    self.tagNames = [rawTagNams componentsSeparatedByString: @";"];
    
    NSArray *photoNameArr = [dict objectForKey:@"photos"];
    for(int i = 0 ;i<photoNameArr.count;i++){
        NSDictionary *photoObj = photoNameArr[i];
        [self.photoNames addObject: [photoObj objectForKey:@"url"]];
    }
    NSLog(@"fid: %d",(int)self.fid);
    for(NSString *str in self.tagNames){
        NSLog(@"tag....: %@",str);
    }
    
    NSLog(@"description: %@",self.food_description);
    if (photoNameArr.count>0) {
            NSLog(@"url: %@",self.photoNames[0]);
    }

    
    return self;
}


/****************************************
 
 Async request
 
 ****************************************/

//fetch async food info
-(void) fetchAsyncInfoCompletion:(void (^)(NSError *err, BOOL success))block{
    _loadingFoodInfo = YES;
    _foodInfoCompletionBlock = block;
    [self.async getFoodInfo_byPost:self.title andLanguage:[[ShareData shareData]defaultTargetLang]];
    
    //[self.async getFoodInfo:self.title andLang:[[ShareData shareData] defaultTargetLang]];
    
}

//fetch async comment
//-(void) fetchCommentsCompletion:(void (^)(NSError *err, BOOL success))block
//{
//    _loadingComments = YES;
//    _commentCompletionBlock = block;
//    
//    //NSLog(@"++++++++++++FOOD++++++++ : %d",self.fid);
//   [self.async getReviews_fid:self.fid withLoadSize:5 andSkip:0];
//    
//}

-(void) fetchLatestCommentsSize:(NSUInteger)size andSkip:(NSUInteger)skip completion:(void (^)(NSError *err, BOOL success))block {
    _loadingComments = YES;
    _commentCompletionBlock = block;
    
    //NSLog(@"++++++++++++FOOD++++++++ : %d",(int)self.fid);
    [self.async getReviews_fid:self.fid withLoadSize:size andSkip:skip];
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

    NSURLRequest *nowRequest = [connection currentRequest];
    
    if ([[nowRequest HTTPMethod] isEqualToString:@"POST"]) {
        
        //Get the body of the request and format as JSON
        NSDictionary *requestBody = [NSJSONSerialization JSONObjectWithData:[nowRequest HTTPBody] options:0 error:nil];
        
        //Get action
        NSString *action = [[requestBody objectForKey:@"action"] stringValue];
        
        if ([action isEqualToString:@"get_review"]) {
            NSLog(@"+++ FOOD +++ : GET review failure");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _foodInfoCompletionBlock(error,NO);
                _loadingComments = NO;
            });
        }
        else if([action isEqualToString:@"get_food"]){
            NSLog(@"+++ FOOD +++ : GET food failure");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _foodInfoCompletionBlock(error,NO);
                _loadingFoodInfo = NO;
            });
            
        }
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{    //async

    
    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    NSLog(@"Return JSON: %@",tmp);
    
    //1.get food info
    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];

    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];

    NSString *action = [returnJSONtoNSdict objectForKey:@"action"];
    
    if(status){ //if we get food info back

        
        if([action isEqualToString:@"get_food"]){//food

            
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            
            if(resultArr.count ==0){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _foodInfoCompletionBlock(nil,NO);
                    _loadingComments = NO;
                });
            }
            else{
                NSDictionary *foodObj = resultArr[0];
                
                self.fid = [[foodObj objectForKey:@"fid"] intValue];
                self.food_description = [foodObj objectForKey:@"description"];
                self.rate = [[foodObj objectForKey:@"rate"] floatValue];
                
                NSString *rawTagNams = [foodObj objectForKey:@"tags"];
                self.tagNames = [rawTagNams componentsSeparatedByString: @";"];
                
                NSArray *photoNameArr = [foodObj objectForKey:@"photos"];
                for(int i = 0 ;i<photoNameArr.count;i++){
                    NSDictionary *photoObj = photoNameArr[i];
                    [self.photoNames addObject: [photoObj objectForKey:@"url"]];
                }
                
                
                NSLog(@"fid: %d",(int)self.fid);
                for(NSString *str in self.tagNames){
                    NSLog(@"tag....: %@",str);
                }
                
                NSLog(@"description: %@",self.food_description);
                if (photoNameArr.count>0) {
                        NSLog(@"url: %@",self.photoNames[0]);
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    _foodInfoCompletionBlock(nil,YES);
                    _foodInfoComplete = YES;
                    _loadingFoodInfo = NO;
                });
            }
            

            
            
        }else if([action isEqualToString:@"get_review"]){//comment

            //create comment array data and assign to self.comments
            
            //....
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            //NSLog(@"+++FOOD+++: I get %d comments for %@",(int)resultArr.count,self.title);
            
            for(int i = 0 ;i<resultArr.count;i++){
                
                NSDictionary *commentsObj = resultArr[i];
                
                
//                NSUInteger cid = [[commentsObj objectForKey:@"rid"] intValue];
//                NSUInteger fid = [[commentsObj objectForKey:@"fid"] intValue];
//                NSUInteger rate = [[commentsObj objectForKey:@"rate"] intValue];
//                NSUInteger like = [[commentsObj objectForKey:@"likes"] intValue];
//                NSUInteger dislike = [[commentsObj objectForKey:@"dislikes"] intValue];
// 
//                NSString *commentWord = [commentsObj objectForKey:@"comments"];
//
//                
//                NSDictionary *creator = [commentsObj objectForKey:@"review_creater"];
//                
//                NSString *selfie = [creator objectForKey:@"selfie"];
//                NSUInteger uid = [[creator objectForKey:@"uid"] intValue];
//                NSUInteger privilege = [[creator objectForKey:@"privilege"] intValue];
//                NSString *name = [creator objectForKey:@"name"];
//                
//                OtherUser *byUser = [[OtherUser alloc] initWithUid:uid andUname:name andUtype:privilege andUselfie:selfie];
//                
//                //init comment object
//                Comment *com = [[Comment alloc] initWithCommentID:cid andFid:fid andRate:rate andLike:like andDisLike:dislike andComment:commentWord andByUser:byUser];
                Comment *com = [[Comment alloc]initWithDict:commentsObj];
                [self.comments addObject: com];

            }
            

            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(nil,YES);
                _commentLoaded = YES;
                _loadingComments = NO;
            });
        }
        

        
    }else{  //failed

        
        if([action isEqualToString:@"get_food"]){   //food
            NSLog(@"+++ FOOD +++ : FAILURE - GET 0 FOOD RECORD!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _foodInfoCompletionBlock(nil,NO);
                _loadingFoodInfo = NO;
            });
            
        }else if([action isEqualToString:@"get_reviews"]){        //comment
            
            NSLog(@"+++ FOOD +++ : FAILURE - GET 0 REVIEW RECORD!");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(nil,NO);
                _loadingComments = NO;
            });
        }


    }
    
}



-(NSString *)description
{
    NSString *desc  = [NSString stringWithFormat:@"Title: %@, transTitle: %@, queryTimes: %d", self.title, self.transTitle,(int)self.queryTimes];
	return desc;
}



@end
