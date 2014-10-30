//
//  ForumListItemStore.m
//  Forum
//
//  Created by DI LIU on 7/31/14.
//  Copyright (c) 2014 DI LIU. All rights reserved.
//

#import "ForumListItemStore.h"

@interface ForumListItemStore ()

@property (nonatomic) NSMutableArray *privateItems;

@end

@implementation ForumListItemStore

- (void)copyAllItems:(NSArray *)theArray
{
    [self.privateItems addObjectsFromArray: theArray];
}

- (void)removeAllItems
{
    [self.privateItems removeAllObjects];
}

- (void)addItem:(ForumListItem *)theItem
{
    [self.privateItems addObject: theItem];
}

- (NSArray *)allItems
{
    return _privateItems;
}

+ (instancetype)sharedStore
{
    static ForumListItemStore *sharedStore = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once( &onceToken, ^{
        sharedStore = [[self alloc] init];
    });
    
    return sharedStore;
}

- (instancetype)init
{
    self = [super init];
    if ( self ) {
        self.privateItems = [[NSMutableArray alloc] initWithCapacity: 0];
    }
    
    return self;
}

@end
