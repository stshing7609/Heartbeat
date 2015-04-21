//
//  SoundBuddy.m
//  IGMHorrorStoryPlayer
//
//  Created by Student on 11/23/13.
//  Copyright (c) 2013 Steven Shing. All rights reserved.
//

#import "SoundBuddy.h"

static float const kSoundDefaultVolume = .6;
static float const kSoundBackgroundDefaultVolume = .25;

@implementation SoundBuddy
{
    NSMutableDictionary *_soundDictionary;
}

- (id)init
{
    self = [super init];
    if(self)
    {
        _soundDictionary = [NSMutableDictionary dictionary];
        [self createChannel: kSoundGameOver];
        [self createChannel: kSoundHit];
        [self createChannel: kSoundHpUp];
        [self createChannel: kSoundPill];
    }
    return self;
}


-(void)playSound:(NSString *)fileName
{
    AVAudioPlayer *player = _soundDictionary[fileName];
    player.currentTime = 0;
    [player play];
}

-(void) createChannel:(NSString*)fileName
{
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    NSError *error;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:&error];
    player.volume = kSoundDefaultVolume;
    [player prepareToPlay];
    
    _soundDictionary[fileName] = player;
}

@end
