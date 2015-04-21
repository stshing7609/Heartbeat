//
//  DataStore.m
//  National Parks
//
//  Created by Steven Shing on 3/16/14.
//  Copyright (c) 2014 Steven Shing. All rights reserved.
//

#import "DataStore.h"

@implementation DataStore

// DataStore is a Singleton
+ (instancetype)sharedStore {
    static DataStore *sharedStore = nil;
    
    if(!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton"
                                   reason:@"Use +[DataStore sharedStore]!"
                                 userInfo:nil];
    return nil;
}

// A private initializer
- (instancetype)initPrivate {
    self = [super init];
    if(self) {
        self.heartRate = 0;
        self.isPlaying = NO;
    }
    return self;
}

@end
