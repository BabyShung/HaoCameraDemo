//
//  Dictionary.m
//  TestDB
//
//  Created by MEI C on 6/4/14.
//  Copyright (c) 2014 dbtest. All rights reserved.
//

#import "Dictionary.h"
#import "DBOperation.h"

@interface Dictionary()
@property (nonatomic,readwrite) TargetLang lang;
@property (strong,nonatomic) DBOperation *opration;
@end

@implementation Dictionary

-(instancetype) initDictInLang:(TargetLang) lang
{
    self = [super init];
    self.lang = lang;
    return self;
    
}
-(DBOperation *)opration
{
    if (!_opration) {
        _opration = [[DBOperation alloc] init];
    }
    return _opration;
}


-(NSArray *) lookupOCRString:(NSString *)inputStr foundKeywords:(NSMutableArray *)keywords
{
    if (!keywords) {
        keywords = [[NSMutableArray alloc]init];
    }
    if ([keywords count]!=0) {
        keywords = nil;
    }
    
    NSLog(@"Start Local search %@",inputStr);
    
    NSArray *words =[self splitAndFilterWordsFromString:inputStr];
    
    NSLog(@"pre search: terms count = %d", words.count);
    
    NSMutableArray *translations= [self.opration searchWords:words getKeywords:keywords inLangTable:self.lang];
    NSLog(@"pro search 1: results count = %d",translations.count);
    
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
    NSLog(@"pro search 2: keywords count = %d, results count = %d",keywords.count,translations.count);
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
//    if (err) {
//        [self throwDictExceptionCausedBy:@"Fail to read filter words"];
//    }
    
    
    //Exclude filter words from string
//    for (int i = 0; i<numOfWords; i++) {
//        NSString *word = words[i];
//        if ([filter rangeOfString:[word lowercaseString]].location != NSNotFound) {
//            [words removeObjectAtIndex:i];
//            i--;
//            numOfWords--;
//        }
//    }
    
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
