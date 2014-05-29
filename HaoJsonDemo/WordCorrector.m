//
//  WordCorrector.m
//  EdibleCameraApp
//
//  Created by CharlieGao on 5/26/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "WordCorrector.h"

@implementation WordCorrector: NSObject



-(NSString*)correctWord: (NSString*)input{
    
    UITextChecker *checker = [[UITextChecker alloc] init];
    NSString *testString = input;
    NSRange checkRange = NSMakeRange(0, testString.length);
    NSRange misspelledRange = [checker rangeOfMisspelledWordInString:testString
                                                               range:checkRange
                                                          startingAt:checkRange.location
                                                                wrap:NO
                                                            language:@"en_US"];
    NSArray *arrGuessed = [checker guessesForWordRange:misspelledRange inString:testString language:@"en_US"];
    if (misspelledRange.location != NSNotFound){
        testString = [testString stringByReplacingCharactersInRange:misspelledRange
                                                         withString:[arrGuessed objectAtIndex:0]];
    }
    //    for (int i=0; i<1; i++) {
    //        NSLog(@"This is it: %@",arrGuessed[i]);
    //    }
    return testString;
    
}
@end
