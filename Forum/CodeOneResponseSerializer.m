//
//  CodeOneResponseSerializer.m
//  Forum
//
//  Created by DI LIU on 8/12/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "CodeOneResponseSerializer.h"

@implementation CodeOneResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    NSString *rawHtml = [super responseObjectForResponse: response
                                                    data: data
                                                   error: error];
    __block NSArray *responseArray;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern: @"(.*?)loginhash=(\\w+)\">(.*?)name=\"formhash\" value=\"(.*?)\"(.*?)<input name=\"sechash\" type=\"hidden\" value=\"(.*?)\" />"
                                  options: NSRegularExpressionDotMatchesLineSeparators
                                  error: error];
    
    [regex enumerateMatchesInString: rawHtml
                            options: 0
                              range: NSMakeRange(0, rawHtml.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             NSString *loginhash = [rawHtml substringWithRange: [result rangeAtIndex: 2]];
                             NSString *formhash = [rawHtml substringWithRange: [result rangeAtIndex: 4]];
                             NSString *sechash = [rawHtml substringWithRange: [result rangeAtIndex: 6]];
                             
                             responseArray = @[ loginhash, formhash, sechash ];
                         }];
    
    return responseArray;
}

@end
