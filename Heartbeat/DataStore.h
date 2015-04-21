//
//  DataStore.h
//  National Parks
//
//  Created by Steven Shing on 3/16/14.
//  Copyright (c) 2014 Steven Shing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataStore : NSObject
@property (nonatomic) int heartRate;
@property (nonatomic) BOOL isPlaying;

+ (instancetype)sharedStore;
@end
