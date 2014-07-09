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
#import "AppDelegate.h"

@implementation User


static edibleBlock CompletionBlock;
static NSMutableData *webdata;
static NSString *password;
static User *sharedInstance = nil;
static AsyncRequest *async;


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
            sharedInstance.latestComment = nil;
            
            webdata = [[NSMutableData alloc]init];
        });
        
    }
    return sharedInstance;
}


- (NSString *)description   //toString description
{
	NSString *desc  = [NSString stringWithFormat:@"\n Uid: %d,\n Uname: %@,\n Email: %@,\n Utype: %d,\n Uselfie: %@,\n pwd: %@\n", (int)self.Uid, self.name,self.email, (int)self.type, self.selfie?@"Yes":@"Nil",self.pwd];
	return desc;
}

+(void)ClearUserInfo{
    NSLog(@"----- User info clear----");
    sharedInstance.Uid = 0;
    sharedInstance.email = nil;
    sharedInstance.name =nil;
    sharedInstance.pwd = nil;
    sharedInstance.type = 0;
    sharedInstance.selfie = nil;
    sharedInstance.latestComment = nil;
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
    if(!sharedInstance)
        [self sharedInstanceWithUid:0 andEmail:email andUname:nil andUpwd:password andUtype:0 andUselfie:nil];
    async = [[AsyncRequest alloc] initWithDelegate:sharedInstance];
    [async login_withEmail:email andPwd:pwd];
}

+(void)registerWithEmail:(NSString *) email andName:(NSString *)name andPwd:(NSString *)pwd andCompletion:(void (^)(NSError *err, BOOL success))block{
    //use md5 here
    edi_md5 *edimd5 = [[edi_md5 alloc]init];
    password = [edimd5 md5:pwd];
    
    CompletionBlock = block;
    if(!sharedInstance)
        [self sharedInstanceWithUid:0 andEmail:email andUname:nil andUpwd:password andUtype:0 andUselfie:nil];
    async = [[AsyncRequest alloc] initWithDelegate:sharedInstance];
    [async signup_withEmail:email andName:name andPwd:pwd];
}

+(void)fetchMyCommentOnFood:(NSUInteger)fid andCompletion:(void (^)(NSError *err, BOOL success))block{
    CompletionBlock = block;
    [async getReviews_fid:fid byUid:[User sharedInstance].Uid];
}

+(void)createComment:(Comment *)comment andCompletion:(void (^)(NSError *err, BOOL success))block{
    CompletionBlock = block;
    [async doComment:comment];
}

+(NSDictionary*)toDictionary{
    
    if(!sharedInstance.Uid)
        return nil;
    
    NSNumber *uidNumber = [NSNumber numberWithInt:(int)sharedInstance.Uid];
    NSNumber *typeNumber = [NSNumber numberWithInt:(int)sharedInstance.type];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:uidNumber, @"uid",sharedInstance.email, @"email",sharedInstance.name, @"name",sharedInstance.pwd,@"pwd",typeNumber,@"type",sharedInstance.selfie,@"selfie", nil];
    
    return dict;
}

+(User *)fromDictionaryToUser:(NSDictionary *)dict{
    
    NSUInteger uid = [[dict objectForKey:@"uid"] intValue];
    NSString *email = [dict objectForKey:@"email"];
    NSString *name = [dict objectForKey:@"name"];
    NSString *pwd = [dict objectForKey:@"pwd"];
    NSUInteger type = [[dict objectForKey:@"type"] intValue];
    NSString *selfie = [dict objectForKey:@"selfie"];
    
    //second login, but remember to init async
    async = [[AsyncRequest alloc] initWithDelegate:sharedInstance];
    
    return [self sharedInstanceWithUid:uid andEmail:email andUname:name andUpwd:pwd andUtype:type andUselfie:selfie];
}

+(User *)anonymousLogin{
    async = [[AsyncRequest alloc] initWithDelegate:sharedInstance];
    
    return [self sharedInstanceWithUid:1 andEmail:@"Anonymous@edible.com" andUname:@"Anonymous" andUpwd:nil andUtype:0 andUselfie:@"default_selfie.png"];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"OOPS", nil) message:NSLocalizedString(@"ERROR_NETWORK", nil) delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
    
    //also set things back
    if (CompletionBlock) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CompletionBlock(error,NO);
        });
    }

}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{    //async
    
    //NSLog(@"%@",[[connection currentRequest] URL]);
    
    NSString *tmp = [[NSString alloc] initWithData:webdata encoding:NSUTF8StringEncoding];
    NSLog(@"!Return JSON: %@",tmp);
    
    //1.get food info
    NSDictionary *returnJSONtoNSdict = [NSJSONSerialization JSONObjectWithData:webdata options:0 error:nil];
    
    int status = [[returnJSONtoNSdict objectForKey:@"status"] intValue];
    //NSString *log = [returnJSONtoNSdict objectForKey:@"log"];
    
    NSString *action = [returnJSONtoNSdict objectForKey:@"action"];
    
    if(status){ //if we get food info back
        
        if([action isEqualToString:@"login"]){//login
            [self configureUser:returnJSONtoNSdict];
        }else  if([action isEqualToString:@"register"]){
            [self configureUser:returnJSONtoNSdict];
        }else if ([action isEqualToString:@"post_update"]){
            if (CompletionBlock) {
                CompletionBlock(nil,YES);
            }
        }
        else{//get my review
            NSArray *resultArr = [returnJSONtoNSdict objectForKey:@"result"];
            if (resultArr.count == 1) {
                [User sharedInstance].latestComment = [[Comment alloc]initWithDict:resultArr[0]];
            }else{
                [User sharedInstance].latestComment = nil;
            }
            if (CompletionBlock) {
                CompletionBlock(nil,YES);
            }
            
        }
    }else{
        NSLog(@"failed!!!!!!!!!!!!!!");
        
        if([action isEqualToString:@"login"]){//login

            [self configureError:NSLocalizedString(@"ERROR_LOGIN", nil)];
        }
        else if([action isEqualToString:@"register"]){   //PS: bugs in server!! only show this
            [self configureError:NSLocalizedString(@"ERROR_REGISTER", nil)];

        }
        
        if (CompletionBlock) {
            CompletionBlock(nil,NO);
        }
    }
    
}

-(void)configureError:(NSString *)errMsg{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        NSString *log = errMsg;
        [details setValue:log forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        NSError *error = [NSError errorWithDomain:@"LoginReg" code:200 userInfo:details];
        CompletionBlock(error,NO);
    });
}

-(void)configureUser:(NSDictionary *)returnJSONtoNSdict{
    NSDictionary *info = [returnJSONtoNSdict objectForKey:@"result"];
    NSUInteger uid = [[info objectForKey:@"uid"] intValue];
    NSString *uselfie = [info objectForKey:@"selfie"];
    NSString *uemail = [info objectForKey:@"email"];
    NSString *uname = [info objectForKey:@"name"];
    NSUInteger utype = [[info objectForKey:@"privilege"] intValue];
    
    [User sharedInstanceWithUid:uid andEmail:uemail andUname:uname andUpwd:password andUtype:utype andUselfie:uselfie];
    if (CompletionBlock) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            CompletionBlock(nil,YES);
            
        });
    }
}

+(void)logout{
    /************************
     
     log out release things
     
     ************************/
    
    //release camera resource
    AppDelegate *appDlg = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [appDlg closeCamera];
    
    //set user to nil
    [User ClearUserInfo];
    
    //clear userdefault for second login
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentUser"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentUser"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    NSLog(@"click log out");
}
@end
