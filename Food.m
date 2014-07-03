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
        
        self.title = title;
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
    self.title = [dict objectForKey:@"title"];
    self.transTitle = [dict objectForKey:@"name"];
    self.food_description = [dict objectForKey:@"description"];
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
    NSLog(@"url: %@",self.photoNames[0]);
    
    return self;
}


/****************************************
 
 Async request
 
 ****************************************/

//fetch async food info
-(void) fetchAsyncInfoCompletion:(void (^)(NSError *err, BOOL success))block{
    _loadingFoodInfo = YES;
    _foodInfoCompletionBlock = block;
    
    [self.async getFoodInfo:self.title andLang:[[ShareData shareData] defaultTargetLang]];
    
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

-(void) fetchOldestCommentsSize:(NSUInteger)size andSkip:(NSUInteger)skip completion:(void (^)(NSError *err, BOOL success))block {
    _loadingComments = YES;
    _commentCompletionBlock = block;
    
    NSLog(@"++++++++++++FOOD++++++++ : %d",(int)self.fid);
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
    if ([[nowRequest HTTPMethod] isEqualToString:@"GET"]) {
        NSString *urlStr = [[nowRequest URL] absoluteString];
        if([urlStr rangeOfString:@"food"].location != NSNotFound )
        {
            _loadingFoodInfo = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                _foodInfoCompletionBlock(error,NO);
            });
        }
        else if ([urlStr rangeOfString:@"review"].location != NSNotFound )
        {
            _loadingComments = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(error,NO);
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
            _foodInfoComplete = YES;
            _loadingFoodInfo = NO;
            
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            
            if(resultArr.count ==0)
                return;
            
            
            NSDictionary *foodObj = resultArr[0];
            
            self.fid = [[foodObj objectForKey:@"fid"] intValue];
            self.food_description = [foodObj objectForKey:@"description"];
            
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
            NSLog(@"url: %@",self.photoNames[0]);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _foodInfoCompletionBlock(nil,YES);
            });
            
            
        }else if([action isEqualToString:@"get_reviews"]){//comment
            _commentLoaded = YES;
            _loadingComments = NO;
            //create comment array data and assign to self.comments
            
            //....
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            //NSLog(@"+++FOOD+++: I get %d comments for %@",(int)resultArr.count,self.title);
            for(int i = 0 ;i<resultArr.count;i++){
                
                NSDictionary *commentsObj = resultArr[i];
                
                NSUInteger cid = [[commentsObj objectForKey:@"rid"] intValue];
                NSUInteger fid = [[commentsObj objectForKey:@"fid"] intValue];
                NSUInteger rate = [[commentsObj objectForKey:@"rate"] intValue];
                NSUInteger like = [[commentsObj objectForKey:@"likes"] intValue];
                NSUInteger dislike = [[commentsObj objectForKey:@"dislikes"] intValue];
 
                NSString *commentWord = [commentsObj objectForKey:@"comments"];

                
                NSDictionary *creator = [commentsObj objectForKey:@"review_creater"];
                
                NSString *selfie = [creator objectForKey:@"selfie"];
                NSUInteger uid = [[creator objectForKey:@"uid"] intValue];
                NSUInteger privilege = [[creator objectForKey:@"privilege"] intValue];
                NSString *name = [creator objectForKey:@"name"];

                OtherUser *byUser = [[OtherUser alloc] initWithUid:uid andUname:name andUtype:privilege andUselfie:selfie];
                
                //init comment object
                Comment *com = [[Comment alloc] initWithCommentID:cid andFid:fid andRate:rate andLike:like andDisLike:dislike andComment:commentWord andByUser:byUser];
                [self.comments addObject: com];

            }
            

            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(nil,YES);
            });
        }
        

        
    }else{  //failed

        
        if([action isEqualToString:@"get_food"]){   //food
            _loadingFoodInfo = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                _foodInfoCompletionBlock(nil,NO);
            });
            
        }else if([action isEqualToString:@"get_reviews"]){        //comment
            _loadingComments = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(nil,NO);
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
