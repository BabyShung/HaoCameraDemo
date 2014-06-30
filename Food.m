//
//  Food.m
//  EdibleCameraApp
//
//  Created by Hao Zheng on 6/27/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "Food.h"
#import "AsyncRequest.h"

const NSString *title = @"Title";
const NSString *translation = @"Translation";
const NSString *description = @"Decription";
const NSString *tags = @"Tags";
const NSString *photos = @"Photos";
const NSString *comments = @"Comments";

typedef void (^edibleBlock)(NSError *err, BOOL success);

@interface Food()

@property (nonatomic,readwrite,getter = isFoodInfoCompleted) BOOL foodInfoComplete;

@property (nonatomic,readwrite,getter = isCommentLoaded) BOOL commentLoaded;

@property (nonatomic,strong) AsyncRequest *async;
@property (strong,nonatomic) NSMutableData *webdata;
@property (nonatomic, copy) edibleBlock foodInfoCompletionBlock;
@property (nonatomic, copy) edibleBlock commentCompletionBlock;
@end

@implementation Food

//Local search use this to init Food
-(instancetype)initWithTitle:(NSString *)title andTranslations:(NSString *)translate
{
    self = [super init];
    self.foodInfoComplete = NO;
    self.commentLoaded = NO;
    self.title = title;
    self.transTitle = translate;
    self.food_description = @"";
    _webdata = [[NSMutableData alloc]init];
    _async = [[AsyncRequest alloc]initWithDelegate:self];
    _photoNames = [NSMutableArray array];
    _tagNames = [NSMutableArray array];
    _comments = [NSMutableArray array];
    return self;
}



/****************************************
 
 Async request
 
 ****************************************/

//fetch async food info
-(void) fetchAsyncInfoCompletion:(void (^)(NSError *err, BOOL success))block{

    _foodInfoCompletionBlock = block;
    
    [self.async getFoodInfo:self.title andLanguage:@"CN"];
    
}

//fetch async comment
-(void) fetchCommentsCompletion:(void (^)(NSError *err, BOOL success))block
{
    _commentCompletionBlock = block;
    
    
    [self.async getReviews_fid:self.fid];
    
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

    //if error, put error to block
//    if(_isFoodRequest){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _foodInfoCompletionBlock(error,NO);
//        });
//    }else{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _commentCompletionBlock(error,NO);
//        });
//    }
    

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{    //async
    
    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    NSLog(@"***************Hao testing: %@",tmp);
    
    

    
    //1.get food info
    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];

    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];

    NSString *action = [returnJSONtoNSdict objectForKey:@"action"];
    
    if(status){ //if we get food info back

        
        if([action isEqualToString:@"get_food"]){//food
            
            self.foodInfoComplete = YES;
            
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            //NSLog(@"count~~: %d",results.count);
            
            NSDictionary *foodObj = resultArr[0];
            
            //self.transTitle = [foodObj objectForKey:@"name"];
            self.fid = [[foodObj objectForKey:@"fid"] intValue];
            self.food_description = [foodObj objectForKey:@"description"];
            
            NSArray *photoNameArr = [foodObj objectForKey:@"photos"];
    
            
            for(int i = 0 ;i<photoNameArr.count;i++){
                NSDictionary *photoObj = photoNameArr[i];
                [self.photoNames addObject: [photoObj objectForKey:@"url"]];
            }
            
            
            NSLog(@"fid: %d",self.fid);
            NSLog(@"description: %@",self.food_description);
            NSLog(@"url: %@",self.photoNames[0]);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _foodInfoCompletionBlock(nil,YES);
            });
            
            
        }else if([action isEqualToString:@"get_reviews"]){//comment
            
            self.commentLoaded = YES;
            //create comment array data and assign to self.comments
            
            //....
            
            
            
            
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(nil,YES);
            });
        }
        

        
    }else{  //failed

        
        if([action isEqualToString:@"get_food"]){        //food
            dispatch_async(dispatch_get_main_queue(), ^{
                _foodInfoCompletionBlock(nil,NO);
            });
            
        }else if([action isEqualToString:@"get_reviews"]){        //comment
            dispatch_async(dispatch_get_main_queue(), ^{
                _commentCompletionBlock(nil,NO);
            });
        }


    }
    
}



-(NSString *)description
{
    NSString *desc  = [NSString stringWithFormat:@"Title: %@, transTitle: %@", self.title, self.transTitle];
	return desc;
}

@end
