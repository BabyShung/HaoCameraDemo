//
//  Dictionary.m
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import "Dictionary.h"
#import "ShareData.h"
#import "DBOperation.h"
#import "Food.h"
#import "AsyncRequest.h"

typedef void (^edibleBlock)(NSArray *results, BOOL success);

@interface Dictionary()

@property (nonatomic,readwrite) TargetLang lang;

@property (strong,nonatomic) DBOperation *operation;

@property (nonatomic,strong) AsyncRequest *async;

@property (strong,nonatomic) NSMutableData *webdata;

@property (nonatomic, copy) edibleBlock searchCompletionBlock;


@property (nonatomic,readwrite,getter = isSearchingFood) BOOL searchingFood;

@end

@implementation Dictionary

-(instancetype) initDictInLang:(TargetLang) lang
{
    self = [super init];
    self.searchingFood = NO;
    self.lang = lang;
    return self;
    
}

-(instancetype) initDictInDefaultLang{
    self = [super init];
    self.lang = [[ShareData shareData] defaultTargetLang];
    return self;
}

-(DBOperation *)operation
{
    if (!_operation) {
        _operation = [[DBOperation alloc] init];
    }
    return _operation;
}

-(NSArray *) localSearchOCRString:(NSString *)inputStr
{
    NSMutableArray *keywords,*foods;
    keywords = [[NSMutableArray alloc]init];
    foods = [[NSMutableArray alloc]init];
    
    NSArray *translates = [self lookupOCRString:inputStr foundKeywords:keywords];
    
    if (keywords.count!=0) {
        for (int i =0;i<keywords.count;i++) {
            Food *food =[[Food alloc]initWithTitle:keywords[i] andTranslations:translates[i]];
            [foods addObject:food];
        }
        return foods;
    }
    else{
        return nil;
    }
    
}

-(void) serverSearchOCRString:(NSString *)inputStr andCompletion:(void (^)(NSArray *results, BOOL success))block
{
    _searchingFood = YES;
    _searchCompletionBlock = block;
    [self.async getFoodInfo:inputStr andLang:self.lang];
}

//Local search an ocr string
-(NSArray *) lookupOCRString:(NSString *)inputStr foundKeywords:(NSMutableArray *)keywords
{
    if (!keywords) {
        keywords = [[NSMutableArray alloc]init];
    }
    if ([keywords count]!=0) {
        keywords = nil;
    }
    
    NSArray *words = [self splitAndFilterWordsFromString:inputStr];
    NSMutableArray *translations= [self.operation searchWords:words getKeywords:keywords inLangTable:self.lang];
    
    //Exclude keywords which are substrings of other keywords
    NSInteger count = keywords.count;
    for (int i =0; i<count; i++) {
        BOOL isASubstring = FALSE;
        for (int j=0; j<count; j++) {
            if (i==j || [keywords[i] length] > [keywords[j] length]) {
                continue;
            }
            //check if i is a substring of j
            if ([keywords[j] rangeOfString:keywords[i]].location != NSNotFound) {
                
                //i is a substring of j,mark it
                isASubstring = TRUE;
                break;
            }
        }
        if (isASubstring) {
            [keywords removeObjectAtIndex:i];
            [translations removeObjectAtIndex:i];
            count--;
            i--;
        }
    }
    return translations;

}


-(NSArray *)splitAndFilterWordsFromString:(NSString *)str
{
    //Devide string into words
    NSMutableArray *words = [NSMutableArray arrayWithArray:[str componentsSeparatedByCharactersInSet:
                                                            [NSCharacterSet whitespaceCharacterSet]]] ;
    NSInteger numOfWords = words.count;
    
    //Get filter words as a string
//    NSError *err;
//    ShareData *sharedata = [ShareData shareData];
//    NSString *filter=[NSString stringWithContentsOfFile:[sharedata writableFilterWordsFilePath] encoding:NSUTF8StringEncoding error:&err];
//    if (!err) {
//        [self throwDictExceptionCausedBy:@"Fail to read filter words"];
//    }
//       
    
    //Exclude filter words from string
//    for (int i = 0; i<numOfWords; i++) {
//        NSString *word = words[i];
//        if ([filter rangeOfString:[word lowercaseString]].location != NSNotFound) {
//            [words removeObjectAtIndex:i];
//            i--;
//            numOfWords--;
//        }
//    }
//    
    //Generate all combination of remain words
    for (int i=0; i<numOfWords-1; i++) {
        NSString *tmpString = words[i];
        for (int j = i+1; j < numOfWords ; j++) {
            tmpString = [tmpString stringByAppendingFormat:@" %@",words[j]];
            [words addObject:tmpString];
        }
    }
    
    return words;
    
}


-(void)throwDictExceptionCausedBy:(NSString *)reason
{
    NSException* ex = [[NSException alloc]initWithName:@"DictionaryFailures" reason:reason userInfo:nil];
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
    NSLog(@"Return JSON: %@",tmp);
    
    //1.get food info
    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];
    
    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
    
    NSString *action = [returnJSONtoNSdict objectForKey:@"action"];
    
    if(status){ //if we get food info back
        
        
        if([action isEqualToString:@"get_food"]){//food
            

            
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            
            if(resultArr.count ==0){
                return;
            }
            NSMutableArray *foodArray = [NSMutableArray array];
            
            for (NSDictionary *foodObj in resultArr) {
                
                
                //NSDictionary *foodObj = resultArr[0];
                Food *food = [[Food alloc]initWithDictionary:foodObj];
                [foodArray addObject:food];
                

            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                _searchingFood = NO;
                _searchCompletionBlock(foodArray,YES);
            });
                
            
            
        }

    }
}
@end
