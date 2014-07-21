//
//  EDTime.m
//  EdibleCameraApp
//
//  Created by MEI C on 7/20/14.
//  Copyright (c) 2014 Hao Zheng. All rights reserved.
//

#import "EDTime.h"


@implementation EDTime

-(instancetype) initWithTimeIntervalSince1970:(NSTimeInterval) interval{
    self = [self init];
    if (self){
        _dateObj = [NSDate dateWithTimeIntervalSince1970:interval];
        
    }
    return self;
}

-(instancetype) initWithDate:(NSDate *)date{
    self = [self init];
    if (self){
        _dateObj = date;
        
    }
    return self;
}

-(instancetype) init{
    self = [super init];
    if (self) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setTimeZone:[NSTimeZone systemTimeZone]];
    }
    return self;
}

-(NSString *)stringFormatedForComment{
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:_dateObj toDate:[NSDate date] options:0];


    switch (dateComp.year) {
        case 0:
            [_formatter setDateFormat:@"M.dd"];
            return [_formatter stringFromDate:_dateObj];
        case 1:
            return AMLocalizedString(@"EDTIME_YEAR_AGO", nil);
        default:
            return [NSString stringWithFormat:@"%d%@",(int)dateComp.year,AMLocalizedString(@"EDTIME_YEARS_AGO", nil)];
    }
}

@end
