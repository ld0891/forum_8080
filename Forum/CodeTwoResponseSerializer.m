//
//  CodeTwoResponseSerializer.m
//  Forum
//
//  Created by DI LIU on 8/12/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "CodeTwoResponseSerializer.h"

@implementation CodeTwoResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    NSString *rawHtml = [super responseObjectForResponse: response
                                                    data: data
                                                   error: error];
    
    __block NSString *responseURL;
    
    NSRegularExpression *regex = [NSRegularExpression
                                  regularExpressionWithPattern: @"src=\"(.*?)\" "
                                  options: NSRegularExpressionDotMatchesLineSeparators
                                  error: error];
    
    [regex enumerateMatchesInString: rawHtml
                            options: 0
                              range: NSMakeRange(0, rawHtml.length)
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                             
                             responseURL = [rawHtml substringWithRange: [result rangeAtIndex: 1]];
                         }];
    return responseURL;
}


@end
