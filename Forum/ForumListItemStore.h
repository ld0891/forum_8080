//
//  ForumListItemStore.h
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ForumListItem;

@interface ForumListItemStore : NSObject

@property (nonatomic, readonly) NSArray *allItems;

+ (instancetype)sharedStore;
- (void)addItem:(ForumListItem *)theItem;
- (void)removeAllItems;
- (void)copyAllItems:(NSArray *)theArray;

@end
