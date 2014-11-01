//
//  PostListResponseSerializer.m
//  Forum
//
//  Created by DI LIU on 8/5/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "PostListResponseSerializer.h"
#import "ForumListItemStore.h"
#import "ForumListItem.h"
#import "TFHpple.h"

#import "NSString+HTML.h"

@interface PostListResponseSerializer ()

@end

@implementation PostListResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    NSString *rawHtml = [super responseObjectForResponse: response
                                                    data: data
                                                   error: error];
    __block NSString *nextPageURL;
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];    
    // Begin Parsing
    rawHtml = [rawHtml stringByReplacingOccurrencesOfString: @"\r\n" withString: @"\n"];
    NSRange begin = [rawHtml rangeOfString: @"normalthread_"];
    
    NSString *nextPageRes = [rawHtml substringToIndex: begin.location];
    NSString *res = [rawHtml substringFromIndex: begin.location];

    // Parse the next page url
    NSRegularExpression *nxtRegex = [NSRegularExpression
                                     regularExpressionWithPattern: @"</label><a href=\"(.*?)\\?t=1\" class=\"nxt\">下一页</a>"
                                     options: NSRegularExpressionDotMatchesLineSeparators
                                     error: error];
    [nxtRegex enumerateMatchesInString: nextPageRes
                               options: 0
                                 range: NSMakeRange(0, nextPageRes.length)
                            usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                nextPageURL = [nextPageRes substringWithRange: [result rangeAtIndex: 1]];
                            }];
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern: @"\"normalthread_(\\d+)\">.*?<a href=\"(.*?)\".*?\"xst\" >(.*?)</a>.*?php\\?uid=(\\d+).*?/>\n(.*?)</cite>\n<em><span.*?>(.*?)</span></em>\n</td>\n<td class=\"num\"><span.*?>(\\d+)</span><em>(\\d+)</em>"
                                  options: NSRegularExpressionDotMatchesLineSeparators
                                  error: error
                                  ];
    
    [regex enumerateMatchesInString: res
                            options: 0
                              range: NSMakeRange(0, res.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             ForumListItem *newItem = [[ForumListItem alloc] init];
                             
                             NSString *tid = [res substringWithRange: [result rangeAtIndex: 1]];
                             NSString *url = [res substringWithRange: [result rangeAtIndex: 2]];
                             NSString *title = [res substringWithRange: [result rangeAtIndex: 3]];
                             NSString *uid = [res substringWithRange: [result rangeAtIndex: 4]];
                             NSString *username = [res substringWithRange: [result rangeAtIndex: 5]];
                             NSString *date = [res substringWithRange: [result rangeAtIndex: 6]];
                             NSString *reply = [res substringWithRange: [result rangeAtIndex: 7]];
                             NSString *view = [res substringWithRange: [result rangeAtIndex: 8]];
                             
                             newItem.tid = [NSNumber numberWithInteger: [tid integerValue]];
                             newItem.uid = [NSNumber numberWithInteger: [uid integerValue]];;
                             // Replace HTML entites in title with correct characters.
                             newItem.title = [title correctHtmlEntities];
                             newItem.postDetailURL = url;
                             newItem.posterName = username;
                             newItem.numOfReply = [reply integerValue];
                             newItem.numOfView = [view integerValue];
                             newItem.posterAvatarURL = [NSString stringWithFormat: @"uc_server/avatar.php?uid=%@&size=small", uid];
                             
                             NSString *dateFormatString = @"yyyy-M-d HH:mm";
                             NSString *timeZoneName = @"Asian/Shanghai";
                             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                             [dateFormatter setDateFormat: dateFormatString];
                             [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: timeZoneName]];
                             newItem.postDate = [dateFormatter dateFromString: date];
                             newItem.chineseDate = [self generateStringFromDate: newItem.postDate];
                             newItem.isRead = NO;
                             
                             [responseArray addObject: newItem];
                         }];
    NSDictionary *dic = @{ @"url": (nextPageURL == nil ? @"" : nextPageURL),
                          @"array": responseArray };
    return dic;
}

@end