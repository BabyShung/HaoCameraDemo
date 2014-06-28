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

@interface Dictionary()
@property (nonatomic,readwrite) TargetLang lang;
@property (strong,nonatomic) DBOperation *operation;
@end

@implementation Dictionary

-(instancetype) initDictInLang:(TargetLang) lang
{
    self = [super init];
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

-(void) serverSearchOCRString:(NSString *)inputStr andCompletion:(void (^)(BOOL, NSError *))block
{
    
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

@end
