//
//  NSString+HTML.m
//  极速社区
//
//  Created by DI LIU on 8/26/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "NSString+HTML.h"

@implementation NSString (forum_HTML)

- (NSString *)forum_correctHtmlEntities
{
    NSString *result;
    
    result = [self stringByReplacingOccurrencesOfString: @"&quot;"
                                             withString: @"\""];
    result = [result stringByReplacingOccurrencesOfString: @"&amp;"
                                               withString: @"&"];
    result = [result stringByReplacingOccurrencesOfString: @"&lt;"
                                               withString: @"<"];
    result = [result stringByReplacingOccurrencesOfString: @"&gt;"
                                               withString: @">"];
    
    return result;
}

@end
