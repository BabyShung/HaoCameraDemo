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
#import "WordCorrector.h"

typedef void (^edibleBlock)(NSArray *results, BOOL success);

@interface Dictionary()

@property (nonatomic,readwrite) TargetLang lang;

@property (strong,nonatomic) DBOperation *operation;

@property (nonatomic,strong) AsyncRequest *async;

@property (strong,nonatomic) NSMutableData *webdata;

@property (nonatomic, copy) edibleBlock searchCompletionBlock;

@property (nonatomic,strong)WordCorrector *wordCorrector;


@property (nonatomic,readwrite,getter = isSearchingFood) BOOL searchingFood;

@end

@implementation Dictionary

-(instancetype) initDictInLang:(TargetLang) lang
{
    self = [super init];
    self.searchingFood = NO;
    self.lang = lang;
    self.wordCorrector = [[WordCorrector alloc]init];
    _webdata = [[NSMutableData alloc]init];
    _async = [[AsyncRequest alloc]initWithDelegate:self];
    return self;
    
}

-(instancetype) initDictInDefaultLang{
    self = [super init];
    self.searchingFood = NO;
    self.wordCorrector = [[WordCorrector alloc]init];
    self.lang = [[ShareData shareData] defaultTargetLang];
    _webdata = [[NSMutableData alloc]init];
    _async = [[AsyncRequest alloc]initWithDelegate:self];
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

-(NSArray *) localBlurSearchString:(NSString *)typeStr
{
    NSMutableArray *foods = [NSMutableArray array];
    
    NSArray *foodDicts = [self.operation blurSearch:typeStr toLang:self.lang];
    
    for (NSDictionary *foodDict in foodDicts) {
        
        Food *food =[[Food alloc]initWithTitle:[foodDict objectForKey:@"keyword"] andTranslations:[foodDict objectForKey:@"translation"] andQueryTimes:0];
        
        [foods addObject:food];
        
    }
    
    return foods;
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
        [self throwDictExceptionCausedBy:@"MutableArray Keywords NOT init"];
    }
    if ([keywords count]!=0) {
        [keywords removeAllObjects];
    }
    
    NSMutableArray *translations= [self.operation searchWords:[self splitAndFilterWordsFromString:inputStr] getKeywords:keywords inLangTable:self.lang];
    
    
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
    //Devide string into words and exclude newline characters
    NSMutableArray *words = [NSMutableArray arrayWithArray:[[str stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsSeparatedByCharactersInSet:
                                                            [NSCharacterSet whitespaceCharacterSet]]] ;
    
    NSMutableArray *words_corrected = [NSMutableArray array];
    for(NSString *word in words){
        NSString *correctedWord = [_wordCorrector correctWord:word];
        correctedWord = [correctedWord stringByTrimmingCharactersInSet:[NSCharacterSet  whitespaceAndNewlineCharacterSet]];
        
        if (![correctedWord isEqual:@""] && ![correctedWord isEqual:@" "] && correctedWord.length > 1){
            [words_corrected addObject: correctedWord];
        }
    }
    
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
    NSMutableString * tmpStr = [[NSMutableString alloc]init];
    NSUInteger numOfWords = words_corrected.count;
    
    int numCombo = 0;
    if(numOfWords != 0){
        for (int i=0; i<numOfWords-1; i++) {
            [tmpStr setString:words_corrected[i]];
            [tmpStr stringByReplacingOccurrencesOfString:@"\r"
                                              withString:@""];
            [tmpStr stringByReplacingOccurrencesOfString:@"\n"
                                              withString:@""];
            numCombo = 0;
            for (int j = i+1; j < numOfWords ; j++) {
                if(numCombo > 4){
                    break; //avoid latency
                }
                [tmpStr appendFormat:@" %@",words_corrected[j]];
                [words_corrected addObject:[NSString stringWithString:tmpStr]];
                numCombo++;
            }
            
        }
    }
    return words_corrected;
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
    _searchingFood = NO;
    _searchCompletionBlock(nil,NO);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{    //async
    
    NSString *tmp = [[NSString alloc] initWithData:_webdata encoding:NSUTF8StringEncoding];
    NSLog(@"Return JSON: %@",tmp);
    
    //1.get food info
    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:_webdata options:0 error:nil];
    
    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
    
    //NSString *action = [returnJSONtoNSdict objectForKey:@"action"];
    
    if(status){ //if we get food info back
        
        NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
        NSMutableArray *foodArray = [NSMutableArray array];
        
        for (NSDictionary *foodObj in resultArr) {
            //NSDictionary *foodObj = resultArr[0];
            Food *food = [[Food alloc]initWithDictionary:foodObj];
            [foodArray addObject:food];
        }
        _searchingFood = NO;
        _searchCompletionBlock(foodArray,YES);
        
        
    }else{  //failed
        _searchingFood = NO;
        _searchCompletionBlock(nil,NO);
        
    }
    
}
@end
