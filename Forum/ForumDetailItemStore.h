//
//  ForumDetailItemStore.h
//  Forum
//
//  Created by DI LIU on 8/1/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ForumDetailItem;

@interface ForumDetailItemStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

+ (instancetype)sharedStore;
- (void)addItem:(ForumDetailItem *)theItem;
- (void)removeAllItems;
- (void)copyAllItems:(NSArray *)theArray;

@end
