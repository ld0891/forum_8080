//
//  RawResponseSerializer.m
//  Forum
//
//  Created by DI LIU on 8/14/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "RawResponseSerializer.h"

@implementation RawResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    NSString *result = [super responseObjectForResponse: response
                                                   data: data
                                                  error: error];
    return result;
}

@end
