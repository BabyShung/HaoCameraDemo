//
//  User.m
//  EdibleBlueCheese
//
//  Created by Hao Zheng on 4/8/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "User.h"
#import "AsyncRequest.h"
#import "edi_md5.h"
@implementation User

static edibleBlock CompletionBlock;
static NSMutableData *webdata;
static NSString *password;
static User *sharedInstance = nil;

+ (User *)sharedInstance{   //directly get the instance
    return sharedInstance;
}


//static init
+ (User *)sharedInstanceWithUid:(NSUInteger)uid andEmail:(NSString*)email andUname:(NSString*)uname andUpwd:(NSString*)upwd andUtype:(NSUInteger)utype andUselfie:(NSString*)uselfie
{
    User *user = [User sharedInstance];
    if(user){
        user.Uid = uid;
        user.email = email;
        user.name =uname;
        user.pwd = upwd;
        user.type = utype;
        user.selfie = uselfie;
    }else{
        
        static dispatch_once_t oncePredicate;
        
        dispatch_once(&oncePredicate, ^{
            sharedInstance = [[User alloc] init];
            
            sharedInstance.Uid = uid;
            sharedInstance.email = email;
            sharedInstance.name = uname;
            sharedInstance.pwd = upwd;
            sharedInstance.type = utype;
            sharedInstance.selfie = uselfie;
            
            
            webdata = [[NSMutableData alloc]init];
        });
        
    }
    return sharedInstance;
}


- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@"Uid: %d, Uname: %@, Utype: %lu, Uselfie: %@", self.Uid, self.name, (unsigned long)self.type, self.selfie?@"Yes":@"Nil"];
	
	return desc;
}

+(void)ClearUser{
    sharedInstance = nil;
}

+(void)loginWithCompletion:(void (^)(NSError *err, BOOL success))block{
    User *user = [self sharedInstance];
    [self loginWithEmail:user.email andPwd:user.pwd andCompletion:block];
}

+(void)loginWithEmail:(NSString *) email andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block{
    
    
    //use md5 here
    edi_md5 *edimd5 = [[edi_md5 alloc]init];
    password = [edimd5 md5:pwd];
    CompletionBlock = block;
    AsyncRequest *async = [[AsyncRequest alloc] initWithDelegate:self];
    [async login_withEmail:email andPwd:password];
}

+(void)registerWithEmail:(NSString *) email andName:(NSString *)name andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block{
    //use md5 here
    edi_md5 *edimd5 = [[edi_md5 alloc]init];
    password = [edimd5 md5:pwd];
    CompletionBlock = block;
    AsyncRequest *async = [[AsyncRequest alloc] initWithDelegate:self];
    [async signup_withEmail:email andName:name andPwd:password];
}


/****************************************
 
 delegate methods for networkConnection
 
 ****************************************/


-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [webdata setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [webdata appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops.." message:@"Network problem..please try again." delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
    
    //also set things back
    dispatch_async(dispatch_get_main_queue(), ^{
        CompletionBlock(error,NO);
    });
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{    //async
    
    NSString *tmp = [[NSString alloc] initWithData:webdata encoding:NSUTF8StringEncoding];
    NSLog(@"!Return JSON: %@",tmp);
    
    //1.get food info
    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:webdata options:0 error:nil];
    
    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
    
    //NSString *action = [returnJSONtoNSdict objectForKey:@"action"];
    
    if(status){ //if we get food info back
        
        //if([action isEqualToString:@"login"]){//login
            NSDictionary *info = [returnJSONtoNSdict objectForKey:@"result"];
            
            NSUInteger uid = [[info objectForKey:@"uid"] intValue];
            NSString *uselfie = [info objectForKey:@"selfie"];
            NSString *uemail = [info objectForKey:@"email"];
            NSString *uname = [info objectForKey:@"name"];
            NSUInteger utype = [[info objectForKey:@"privilege"] intValue];
            
            [User sharedInstanceWithUid:uid andEmail:uemail andUname:uname andUpwd:password andUtype:utype andUselfie:uselfie];
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                CompletionBlock(nil,YES);
            });
        //}else  if([action isEqualToString:@"register"]){
            
            
       // }
        
        
    }else{
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CompletionBlock(nil,NO);
        });
    }
    
}



@end
