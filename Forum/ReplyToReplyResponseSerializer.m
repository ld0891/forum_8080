//
//  ReplyToReplyResponseSerializer.m
//  极速社区
//
//  Created by DI LIU on 9/7/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ReplyToReplyResponseSerializer.h"
#import "TFHpple.h"

@implementation ReplyToReplyResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    // Initialize XPath
    NSString *noticeauthorXPath = @"//input[@name='noticeauthor']";
    NSString *noticetrimstrXPath = @"//input[@name='noticetrimstr']";
    NSString *noticeauthormsgXPath = @"//input[@name='noticeauthormsg']";
    
    TFHpple *replyInfo = [super hppleResponseObjectForResponse: response
                                                               data: data
                                                              error: error];
    
    TFHppleElement *element = [replyInfo peekAtSearchWithXPathQuery: noticeauthorXPath];
    NSString *noticeauthor = [element objectForKey: @"value"];
    
    element = [replyInfo peekAtSearchWithXPathQuery: noticetrimstrXPath];
    NSString *noticetrimstr = [element objectForKey: @"value"];
    
    element = [replyInfo peekAtSearchWithXPathQuery: noticeauthormsgXPath];
    NSString *noticeauthormsg = [element objectForKey: @"value"];
    
    NSDictionary *dic = @{ @"noticeauthor": noticeauthor,
                           @"noticetrimstr": noticetrimstr,
                           @"noticeauthormsg": noticeauthormsg };
    return dic;
    
    return 0;
}

@end
