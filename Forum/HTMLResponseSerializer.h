//
//  HTMLResponseSerializer.h
//  Forum
//
//  Created by DI LIU on 8/5/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "AFURLResponseSerialization.h"

@interface HTMLResponseSerializer : AFHTTPResponseSerializer

- (NSString *)generateStringFromDate: (NSDate *)theDate;

- (id)hppleResponseObjectForResponse:(NSURLResponse *)response
                                data:(NSData *)data
                               error:(NSError *__autoreleasing *)error;

@end
