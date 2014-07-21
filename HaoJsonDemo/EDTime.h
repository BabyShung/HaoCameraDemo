//
//  EDTime.h
//  EdibleCameraApp
//
//  Created by MEI C on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalizationSystem.h"

@interface EDTime : NSObject

@property (strong,nonatomic) NSDate *dateObj;

@property (strong, nonatomic) NSDateFormatter *formatter;

-(NSString *)stringFormatedForComment;

-(instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) interval;

-(instancetype) initWithDate:(NSDate *)date;

@end
