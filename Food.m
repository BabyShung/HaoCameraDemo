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
        
        self.title = [title capitalizedString] ;
        self.rate = -1;
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
    _photoNames = [NSMutableArray array];
    _tagNames = [NSMutableArray array];
    _comments = [NSMutableArray array];
    
    self.fid = [[dict objectForKey:@"fid"] intValue];
    self.title = [[dict objectForKey:@"title"] capitalizedString];
    self.transTitle = [dict objectForKey:@"name"];
    if (![[dict objectForKey:@"description"] isEqualToString:@"N/A"]) {
        self.food_description = [dict objectForKey:@"description"];
    }else{
        self.food_description = @"";
    }
    self.rate = [[dict objectForKey:@"avg_rate"] floatValue];
    _webdata = [[NSMutableData alloc]init];
    _async = [[AsyncRequest alloc]initWithDelegate:self];
    
    NSString *rawTagNams = [dict objectForKey:@"tags"];
    if (![rawTagNams isEqualToString:@"N/A"]) {
        self.tagNames = [rawTagNams componentsSeparatedByString: @";"];
    }
    
    NSArray *photoNameArr = [dict objectForKey:@"photos"];
    for(int i = 0 ;i<photoNameArr.count;i++){
        NSDictionary *photoObj = photoNameArr[i];
        [self.photoNames addObject: [photoObj objectForKey:@"url"]];
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
}


-(void) fetchLatestCommentsSize:(NSUInteger)size andSkip:(NSUInteger)skip completion:(void (^)(NSError *err, BOOL success))block {
    _loadingComments = YES;
    _commentCompletionBlock = block;
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
        NSString *action = [requestBody objectForKey:@"action"];
        
        if ([action isEqualToString:@"get_review"]) {
            NSLog(@"+++ FOOD +++ : GET review failure");
            
            _commentCompletionBlock(error,NO);
            _loadingComments = NO;
            
        }
        else if([action isEqualToString:@"get_food"]){
            NSLog(@"+++ FOOD +++ : GET food failure");
            
            _foodInfoCompletionBlock(error,NO);
            _loadingFoodInfo = NO;
            
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
                _foodInfoCompletionBlock(nil,NO);
                _loadingComments = NO;
                
            }
            else{
                NSDictionary *foodObj = resultArr[0];
                
                self.fid = [[foodObj objectForKey:@"fid"] intValue];
                if (![[foodObj objectForKey:@"description"] isEqualToString:@"N/A"]) {
                    self.food_description = [foodObj objectForKey:@"description"];
                }
                self.rate = [[foodObj objectForKey:@"avg_rate"] floatValue];
                
                NSString *rawTagNams = [foodObj objectForKey:@"tags"];
                if (![rawTagNams isEqualToString:@"N/A"]) {
                    self.tagNames = [rawTagNams componentsSeparatedByString: @";"];
                }
                NSArray *photoNameArr = [foodObj objectForKey:@"photos"];
                for(int i = 0 ;i<photoNameArr.count;i++){
                    NSDictionary *photoObj = photoNameArr[i];
                    [self.photoNames addObject: [photoObj objectForKey:@"url"]];
                }
                _foodInfoComplete = YES;
                _foodInfoCompletionBlock(nil,YES);
                
                _loadingFoodInfo = NO;
            }
        }else if([action isEqualToString:@"get_review"]){//comment
            
            //create comment array data and assign to self.comments
            
            //....
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            for(int i = 0 ;i<resultArr.count;i++){
                NSDictionary *commentsObj = resultArr[i];
                Comment *com = [[Comment alloc]initWithDict:commentsObj];
                [self.comments addObject: com];
            }
            _commentCompletionBlock(nil,YES);
            _loadingComments = NO;
        }
    }else{  //failed
        if([action isEqualToString:@"get_food"]){   //food
            NSLog(@"+++ FOOD +++ : FAILURE - GET 0 FOOD RECORD!");
            _foodInfoCompletionBlock(nil,NO);
            _loadingFoodInfo = NO;
        }else if([action isEqualToString:@"get_reviews"]){        //comment
            NSLog(@"+++ FOOD +++ : FAILURE - GET 0 REVIEW RECORD!");
            _commentCompletionBlock(nil,NO);
            _loadingComments = NO;
        }
    }
}

-(NSString *)description{
    NSString *desc  = [NSString stringWithFormat:@"Title: %@, transTitle: %@, queryTimes: %d", self.title, self.transTitle,(int)self.queryTimes];
	return desc;
}

@end
