//
//  UserInfoResponseSerializer.m
//  极速社区
//
//  Created by DI LIU on 9/9/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "UserInfoResponseSerializer.h"
#import "ForumUser.h"

@implementation UserInfoResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    NSString *rawHtml = [super responseObjectForResponse: response
                                                    data: data
                                                   error: error];
    rawHtml = [rawHtml stringByReplacingOccurrencesOfString: @"\r\n" withString: @"\n"];
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern: @"<h2 class=\"mt\">\n(.*?) </h2>.*回帖数 (\\d+).*主题数 (\\d+).*target=\"_blank\">(.*?)</a></span>.*注册时间</em>(.*?)</li>"
                                  options: NSRegularExpressionDotMatchesLineSeparators
                                  error: error];
    
    __block ForumUser *user = [[ForumUser alloc] init];
    
    [regex enumerateMatchesInString: rawHtml
                            options: 0
                              range: NSMakeRange(0, rawHtml.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *username = [rawHtml substringWithRange: [result rangeAtIndex: 1]];
                             NSString *reply = [rawHtml substringWithRange: [result rangeAtIndex: 2]];
                             NSString *post = [rawHtml substringWithRange: [result rangeAtIndex: 3]];
                             NSString *level = [rawHtml substringWithRange: [result rangeAtIndex: 4]];
                             NSString *date = [rawHtml substringWithRange: [result rangeAtIndex: 5]];
                             
                             NSString *dateFormatString = @"yyyy-M-d HH:mm";
                             NSString *timeZoneName = @"Asian/Shanghai";
                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                             [dateFormatter setDateFormat: dateFormatString];
                             [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: timeZoneName]];
                             NSDate *regDate = [dateFormatter dateFromString: date];
                             
                             user.name = username;
                             user.numberOfReply = [reply integerValue];
                             user.numberOfPost = [post integerValue];
                             user.level = level;
                             user.registerDate = regDate;
                             
                         }];
    return user;
}

@end
