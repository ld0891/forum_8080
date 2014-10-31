//
//  ForumDetailItemStore.m
//  Forum
//
//  Created by DI LIU on 8/1/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumDetailItemStore.h"

@interface ForumDetailItemStore ()

@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation ForumDetailItemStore

- (void)copyAllItems:(NSArray *)theArray
{
    [self.privateItems addObjectsFromArray: theArray];
}

- (void)removeAllItems
{
    [self.privateItems removeAllObjects];
}

- (void)addItem:(ForumDetailItem *)theItem
{
    [self.privateItems addObject: theItem];
}

- (NSArray *)allItems
{
    return _privateItems;
}

+ (instancetype)sharedStore
{
    static ForumDetailItemStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        sharedStore = [[ForumDetailItemStore alloc] init];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.privateItems = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    
    return self;
}

@end
