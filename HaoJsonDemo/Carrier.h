//
//  Carrier.h
//  MyPolicyCard
//
//  Created by Hao Zheng on 6/19/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Carrier : NSObject

@property (strong,nonatomic) NSString *plan;
@property (strong,nonatomic) NSArray *policyNumber;
@property (strong,nonatomic) NSString *phoneNumber;
@property (strong,nonatomic) NSString *website;
@property (strong,nonatomic) UIImage *image;

-(instancetype)initWithPlan:(NSString *)plan andPolicyNo:(NSArray *)policyNo andPhoneNo:(NSString *) phoneNo andWeb:(NSString *)website;

@end
