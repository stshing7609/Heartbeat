//
//  SoundBuddy.h
//  IGMHorrorStoryPlayer
//
//  Created by Student on 11/23/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

static NSString* const kSoundGameOver = @"gameover";
static NSString* const kSoundHit = @"hit";
static NSString* const kSoundHpUp = @"hpup";
static NSString* const kSoundPill = @"pill";

@interface SoundBuddy : NSObject
- (void) playSound:(NSString *)fileName;
@end
