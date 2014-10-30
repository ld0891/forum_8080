//
//  PostDetailResponseSerializer.m
//  Forum
//
//  Created by DI LIU on 8/6/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "PostDetailResponseSerializer.h"
#import "ForumDetailItemStore.h"
#import "ForumDetailItem.h"
#import "TFHpple.h"

#import "NSString+HTML.h"

@interface PostDetailResponseSerializer ()

@property (nonatomic, weak) NSString *postItemXPath;
@property (nonatomic, weak) NSString *postIDXPath;
@property (nonatomic, weak) NSString *postTitleXPath;
@property (nonatomic, weak) NSString *posterNameXPath;
@property (nonatomic, weak) NSString *posterAvatarXPath;
@property (nonatomic, weak) NSString *postDateXPath;
@property (nonatomic, weak) NSString *dateFormatString;
@property (nonatomic, weak) NSString *timeZoneName;
@property (nonatomic, weak) NSString *imgAddressClass;
@property (nonatomic, weak) NSString *linkAddressClass;
@property (nonatomic, weak) NSString *postDetailContentXPath;
@property (nonatomic, weak) NSString *postDetailHasQuoteXPath;
@property (nonatomic, weak) NSString *postDetailQuoteOneXPath;
@property (nonatomic, weak) NSString *postDetailQuoteTwoXPath;
@property (nonatomic, weak) NSString *nextPageXPath;
@property (nonatomic, weak) NSString *imgOneXPath;
@property (nonatomic, weak) NSString *imgTwoXPath;
@property (nonatomic, weak) NSString *imgThreeXPath;
@property (nonatomic, weak) NSString *formhashXPath;

@end

@implementation PostDetailResponseSerializer

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing *)error
{
    TFHpple *postDetailList = [super hppleResponseObjectForResponse: response
                                                               data: data
                                                              error: error];
    NSMutableArray *responseArray = [[NSMutableArray alloc] init];
    NSString *nextPageURL;
    NSString *formhash;
    
    // Initialize XPaths
    self.postItemXPath = @"//div[@id='postlist']/div[contains(@id,'post_')]";
    self.postIDXPath = @"";
    self.postTitleXPath = @"//a[@id='thread_subject']";
    self.posterNameXPath = @"//td[@class='pls']//div[@class='authi']/a";
    self.posterAvatarXPath = @"//div[@class='avatar']/a/img";
    self.postDateXPath = @"//td[@class='plc']//div[@class='authi']/em";
    self.postDetailContentXPath = @"//div[@class='pcb']//td[@class='t_f']//text()[not(ancestor::blockquote)][not(ancestor::ignore_js_op)]";
    self.postDetailHasQuoteXPath = @"//div[@class='pcb']//td[@class='t_f']//blockquote";
    self.postDetailQuoteOneXPath = @"//text()[normalize-space()]";
    self.postDetailQuoteTwoXPath = @"//font[@color]";
    self.dateFormatString = @"yyyy-M-d HH:mm";
    self.timeZoneName = @"Asian/Shanghai";
    self.imgAddressClass = @"src";
    self.linkAddressClass = @"href";
    self.nextPageXPath = @"//a[@class='nxt']";
    //self.imgOneXPath = @"//ignore_js_op//p[@class='mbn']/a[@href='javascript:;']/img";
    self.imgOneXPath = @"//ignore_js_op//img";
    self.imgTwoXPath = @"//div[@class='pcb']//td[@class='t_f']/ignore_js_op/img";
    self.imgThreeXPath = @"//div[@class='pcb']//td[@class='t_f']/img";
    self.formhashXPath = @"//form[@id='scbar_form']/input[@name='formhash']";
    
    // Get the URL of next page
    TFHppleElement *hppleNextPage = [postDetailList peekAtSearchWithXPathQuery: self.nextPageXPath];
    nextPageURL = [hppleNextPage objectForKey: self.linkAddressClass];
    
    // Get the formhash of post form
    TFHppleElement *hppleFormhash = [postDetailList peekAtSearchWithXPathQuery: self.formhashXPath];
    formhash = [hppleFormhash objectForKey: @"value"];
    
    // One postDetail item stands for a single post
    // Get all postDetail items into an postDetail array
    NSArray *postDetailArray = [postDetailList searchWithXPathQuery: self.postItemXPath];
    
    // Parse the postDetail items one by one
    for ( TFHppleElement *postDetail in postDetailArray ) {
        
        // Create a new ForumDetail Item;
        ForumDetailItem *newItem = [[ForumDetailItem alloc] init];
        
        // Parse the reply ID
        NSString *rawID = [postDetail objectForKey: @"id"];
        NSInteger rawIDInteger = [[rawID stringByReplacingOccurrencesOfString: @"post_"
                                                                   withString: @""] integerValue];
        newItem.replyID = [NSNumber numberWithInteger: rawIDInteger];
        
        // Parse the poster name
        TFHppleElement *hpplePoster = [postDetail firstChildSearchWithXPathQuery: self.posterNameXPath];
        newItem.posterName = hpplePoster.text;
        NSString *rawPosterID = [hpplePoster objectForKey: @"href"];
        NSRange uidRange = [rawPosterID rangeOfString: @"uid="];
        NSString *posterID = [rawPosterID substringFromIndex: uidRange.location + uidRange.length];
        newItem.posterID = [posterID integerValue];
        
        // Parse the poster avatar url
        TFHppleElement *hpplePosterAvatar = [postDetail firstChildSearchWithXPathQuery: self.posterAvatarXPath];
        newItem.posterAvatarURL = [hpplePosterAvatar objectForKey: @"src"];
        newItem.posterAvatarURL = [newItem.posterAvatarURL stringByReplacingOccurrencesOfString: @"middle" withString: @"small"];
        
        // Parse the date and set the Chinese date
        TFHppleElement *hppleDate = [postDetail firstChildSearchWithXPathQuery: self.postDateXPath];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: self.dateFormatString];
        [dateFormatter setTimeZone: [NSTimeZone timeZoneWithName: self.timeZoneName]];
        newItem.postDate = [dateFormatter dateFromString: hppleDate.text];
        newItem.chineseDate = [self generateStringFromDate: newItem.postDate];
        
        
        // Deal with 2 kinds of complicated post content
        // 1. Post Without quote
        // 2. Post With quote
        
        // First, parse the post content anyway
        NSMutableString *postContent = [[NSMutableString alloc] initWithCapacity:0];
        NSArray *currentPostContent = [postDetail searchWithXPathQuery: self.postDetailContentXPath];
        // Because the post content is separated in HTML
        // I have to parse every one of them and then concatenate
        for ( TFHppleElement *element in currentPostContent ) {
            [postContent appendString:element.raw];
            [postContent appendString:@"\n"];
        }
        // Remove some meaningless leftover HTML code
        [postContent replaceOccurrencesOfString: @"&#13;\n" withString: @""
                                        options: NSLiteralSearch range: NSMakeRange(0, [postContent length])];
        
        // Second, deal with the complicated quote
        // Judge whether a post has quote
        TFHppleElement *quotePost = [postDetail firstChildSearchWithXPathQuery: self.postDetailHasQuoteXPath];
        if ( quotePost == NULL ) {
            newItem.hasQuote = NO;
            newItem.quoteContent = @"";
        }
        else {
            newItem.hasQuote = YES;
        }
        
        // Deal with the postDetail with quote
        if ( newItem.hasQuote == YES ) {
            
            NSMutableString *quoteContent = [[NSMutableString alloc] init];

            // Jump over the beginning '\n'
            // Which only appears in a postDetail with quote
            [postContent deleteCharactersInRange: NSMakeRange(0, 2)];
            
            // There are 2 kinds of quote with different HTML code
            // First, judge the current postDetail's quote is 1st or 2nd kind
            NSArray *quoteList = [quotePost searchWithXPathQuery: self.postDetailQuoteTwoXPath];
            if ( [quoteList count] == 2 ) {
                // 2nd kind of quote is easy, just parse and concatenate
                for ( TFHppleElement *element in quoteList ) {
                    [quoteContent appendString: element.text];
                    [quoteContent appendString: @"\n"];
                }
            }
            else {
                // As is with the content, 1st kind of quote appears in multiple blocks
                // of HTML code. So parse and concatenate.
                NSArray *quotePostList = [quotePost searchWithXPathQuery: self.postDetailQuoteOneXPath];
                for ( TFHppleElement *element in quotePostList ) {
                    [quoteContent appendString: element.raw];
                    [quoteContent appendString: @"\n"];
                }
                // Remove some meaningless HTML code
                [quoteContent replaceOccurrencesOfString: @"&#13;\n"
                                              withString: @""
                                                 options: NSLiteralSearch
                                                   range: NSMakeRange(0, [quoteContent length])];
            }
            newItem.quoteContent = [quoteContent correctHtmlEntities];
        }
        newItem.postContent = [postContent correctHtmlEntities];
        
        // Replace consecutive '\n's with only 2 of them
        NSArray *split = [newItem.postContent componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
        split = [split filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 2"]];
        newItem.postContent = [split componentsJoinedByString: @"\n\n"];
        
        // Deal With Images.
        // First, images in attachments.
        NSArray *hppleImgs = [postDetail searchWithXPathQuery: self.imgOneXPath];
        if ( [hppleImgs count] ) {
            newItem.hasImage = YES;
            for ( TFHppleElement *element in hppleImgs ) {
                [newItem addImgURL: [element objectForKey: @"zoomfile"]];
            }
        }
        
        // Second, In-Line images;
        hppleImgs = [postDetail searchWithXPathQuery: self.imgTwoXPath];
        if ( [hppleImgs count] ) {
            newItem.hasImage = YES;
            for ( TFHppleElement *element in hppleImgs ) {
                [newItem addImgURL: [element objectForKey: @"zoomfile"]];
            }
        }
        
        [responseArray addObject: newItem];
    }
    
    if ( nextPageURL != nil ) {
        NSDictionary *dic = @{@"array": responseArray,
                              @"url": nextPageURL,
                              @"formhash": formhash };
        return dic;
    } else {
        NSDictionary *dic = @{@"array": responseArray,
                              @"url": @"",
                              @"formhash": formhash };
        return dic;
    }
}

@end