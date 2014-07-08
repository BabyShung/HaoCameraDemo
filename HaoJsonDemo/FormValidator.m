//
//  validation.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/9/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "FormValidator.h"

@implementation FormValidator

- (id)init {
    self = [super init];
    if (self) {
        self.errorMsg = [[NSMutableArray alloc]init];
        self.requiredErrorMsg = [[NSMutableArray alloc]init];
        self.samePwdErrorMsg = [[NSMutableArray alloc]init];
        self.emailErrorMsg = [[NSMutableArray alloc]init];
        self.lettersNumbersOnlyMsg = [[NSMutableArray alloc]init];
        self.maxLengthErrorMsg = [[NSMutableArray alloc]init];
        self.minLengthErrorMsg = [[NSMutableArray alloc]init];
    }
    return self;
}

/*********************************
 
 HAO: easy way to validate all
 
 *******************************/
- (void) Email:(NSString *) email andUsername: (NSString *) username andPwd: (NSString *)pwd{
    
    //----pass the textFields
    [self Required:email FieldName:NSLocalizedString(@"Email", nil)];
    //----register case
    if(username){
        [self Required:username FieldName:NSLocalizedString(@"Username", nil)];
    }
    [self Required:pwd FieldName:NSLocalizedString(@"Password", nil)];
    [self Email:email FieldName:NSLocalizedString(@"Email", nil)];
    //----register case
    if(username){
        
        [self MinLength:6 textField:pwd FieldName:NSLocalizedString(@"Password", nil)];
        [self LettersNumbersOnly:username FieldName:NSLocalizedString(@"Username", nil)];
        
        [self MaxLength:20 textField:username FieldName:NSLocalizedString(@"Username", nil)];
        
    }
    [self MaxLength:20 textField:pwd FieldName:NSLocalizedString(@"Password", nil)];
    
}

- (void) OldPwd:(NSString *) oldpwd andNextPwd: (NSString *) nextpwd andConfirmPwd: (NSString *)confirmpwd{
    [self Required:oldpwd FieldName:NSLocalizedString(@"Old password", nil)];
    [self Required:nextpwd FieldName:NSLocalizedString(@"New password", nil)];
    [self Required:confirmpwd FieldName:NSLocalizedString(@"Confirm New password", nil)];
    
    [self MinLength:6 textField:nextpwd FieldName:NSLocalizedString(@"New password", nil)];
    [self MaxLength:20 textField:nextpwd FieldName:NSLocalizedString(@"New password", nil)];
    
    [self SameCheck:nextpwd andConfirm:confirmpwd];
}

- (void) updateOneField:(NSString *) textfield andFieldName:(NSString*)fieldname{
    [self Required:textfield FieldName:fieldname];
    [self LettersNumbersOnly:textfield FieldName:fieldname];
    
}

/***************
 
 Email Address
 
 *************/
-(void) Email: (NSString *) emailAddress FieldName: (NSString *) textFieldName{
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    NSString *msg = NSLocalizedString(@"ERROR_EMAIL", nil);
    if ([emailTest evaluateWithObject:emailAddress] == NO) {//not match
        self.emailError = YES;
        [self.emailErrorMsg addObject:msg];
        return ;
    }else{
        return ;
    }
}

/*******************************
 
 Letters and number, nospace
 
 *****************************/
-(void) LettersNumbersOnly: (NSString *) textField FieldName: (NSString *) textFieldName {
    
    
    //NSString *lettersSpaceRegex = @"^[a-zA-Z0-9]+$";
    NSString *lettersSpaceRegex = @"[a-zA-Z0-9_][a-zA-Z0-9_ ]*";
    NSPredicate *lettersSpaceTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", lettersSpaceRegex];
    
    if([lettersSpaceTest evaluateWithObject:textField] == NO){
        self.lettersNumbersOnly = YES;
        NSString *msg = [NSString stringWithFormat:@"%@%@",textFieldName,NSLocalizedString(@"ERROR_EMAIL_FORMAT", nil)];
        [self.lettersNumbersOnlyMsg addObject:msg];
        return ;
    }else{
        return ;
    }
}

/*******************
 
 Required
 
 *****************/
-(void) Required: (NSString *) textField FieldName: (NSString *) textFieldName {
    
    if (textField.length == 0) {//empty
        self.requiredError = YES;
        NSString *msg = [NSString stringWithFormat:@"%@%@.",NSLocalizedString(@"PLEASE_ENTER", nil),textFieldName];
        [self.requiredErrorMsg addObject:msg];
        return ;
    }else{
        return ;
    }
}

/*************************************
 
 New pwd and confirm pwd same-check
 
 ***********************************/
-(void) SameCheck: (NSString *) textField1 andConfirm:(NSString *) textField2 {
    
    if (![textField1 isEqualToString:textField2]) {//not equal
        self.samePwdError = YES;
        NSString *msg = NSLocalizedString(@"ERROR_PASSWORD_NOT_SAME", nil);
        [self.samePwdErrorMsg addObject:msg];
        return ;
    }else{
        return ;
    }
}

/*******************
 
 MinLength
 
 *****************/
-(void) MinLength: (int) length  textField: (NSString *)textField FieldName: (NSString *) textFieldName{
    
    if(textField.length > length || textField.length == length){
        return ;
    }else{//not match
        self.minLengthError = YES;
        NSString *msg = [NSString stringWithFormat:@"%@%@%d%@.",textFieldName,NSLocalizedString(@"AT_LEAST", nil), length,NSLocalizedString(@"DIGIT", nil)];
        [self.minLengthErrorMsg addObject:msg];
        return ;
    }
}

/*******************
 
 MaxLength
 
 *****************/
- (void) MaxLength: (int) length textField: (NSString *)textField FieldName: (NSString *) textFieldName {
    
    if(textField.length < length || textField.length == length) {
        return ;
    }else{
        self.maxLengthError = YES;
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %d.",textFieldName, NSLocalizedString(@"AT_MOST", nil),length];
        [self.maxLengthErrorMsg addObject:msg];
        return ;
    }
}


/*************************************
 
 Check If TextFields Are Valid
 
 ***********************************/

-(BOOL) isValid {
    
    
    if(self.requiredError){
        for(NSString *msg in self.requiredErrorMsg){
            [self.errorMsg addObject:msg];
        }
        return NO;
        
    }
    
    if(self.emailError) {
        for(NSString *msg in self.emailErrorMsg){
            [self.errorMsg addObject:msg];
        }
        return NO;
    }
    
    
    
    if(self.minLengthError){
        for(NSString *msg in self.minLengthErrorMsg){
            [self.errorMsg addObject:msg];
        }
        return NO;
        
    }
    
    if(self.lettersNumbersOnly){
        for(NSString *msg in self.lettersNumbersOnlyMsg){
            [self.errorMsg addObject:msg];
        }
        return NO;
        
    }
    
    if(self.maxLengthError){
        for(NSString *msg in self.maxLengthErrorMsg){
            [self.errorMsg addObject:msg];
        }
        return NO;
    }
    
    if(self.samePwdError){
        for(NSString *msg in self.samePwdErrorMsg){
            [self.errorMsg addObject:msg];
        }
        return NO;
    }
    
    //add passed, valid it true
    self.textFieldIsValid = TRUE;
    return self.textFieldIsValid;
}


@end
