//
//  HTMLResponseSerializer.m
//  Forum
//
//  Created by DI LIU on 8/5/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "HTMLResponseSerializer.h"
#import "TFHpple.h"

@implementation HTMLResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    return [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
}

- (id)hppleResponseObjectForResponse:(NSURLResponse *)response
                                data:(NSData *)data
                               error:(NSError *__autoreleasing *)error
{
    TFHpple *hpple = [TFHpple hppleWithHTMLData: data encoding: @"NSUTF8StringEncoding"];
    return hpple;
}

// Returns 'today' or 'yesterday' by theDate
- (NSString *)generateStringFromDate: (NSDate *)theDate
{
    NSDate *todayDate = [NSDate date];
    //NSDate *yesterdayDate = [todayDate dateByAddingTimeInterval: -24 * 60 * 60];
    //NSDate *beforeYesterdayDate = [yesterdayDate dateByAddingTimeInterval: -24 * 60 * 60];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-M-d HH:mm"];
    [dateFormat setTimeZone: [NSTimeZone timeZoneWithName:@"Asian/Shanghai"]];
    
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                    startDate:&theDate
                                     interval:NULL
                                      forDate:theDate];
    [[NSCalendar currentCalendar] rangeOfUnit:NSDayCalendarUnit
                                    startDate:&todayDate
                                     interval:NULL
                                      forDate:todayDate];
    NSTimeInterval interval = [todayDate timeIntervalSinceDate: theDate];
    NSTimeInterval aDay = 24 * 60 * 60;
    
    int daysBetween = interval / aDay;
    
    if ( daysBetween == 0 ) {
        return @"今天";
    }
    else if ( daysBetween == 1 ) {
        return @"昨天";
    }
    else if ( daysBetween == 2 ) {
        return @"前天";
    }
    else if ( daysBetween > 9 ){
        return @"以前";
    }
    else {
        return [NSString stringWithFormat: @"%i天前", daysBetween];
    }
}


@end
