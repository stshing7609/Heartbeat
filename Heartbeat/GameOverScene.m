//
//  GameOverScene.m
//  Heartbeat
//
//  Created by Steven Shing on 5/19/14.
//  Copyright (c) 2014 Steven Shing. All rights reserved.
//

#import "GameOverScene.h"
#import "TitleScene.h"

@implementation GameOverScene{
    NSUserDefaults *_highScore;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        bg.alpha = 0.7;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            bg.xScale = 0.9;
            bg.yScale = 1.2;
        }
        _highScore = [[NSUserDefaults alloc] init];
        [self addChild: bg];
        [self createSceneContents];
    }
    return self;
}

-(void)createSceneContents{
    //  GameOver Title
    SKLabelNode *gameoverLabel = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    gameoverLabel.name = @"creditsLabelNode";
    gameoverLabel.text = @"You've been Infected";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        gameoverLabel.fontSize = 60;
        gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    else {
        gameoverLabel.fontSize = 25;
        gameoverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    }
    [self addChild:gameoverLabel];
    
    SKLabelNode *highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    highScoreLabel.name = @"highScoreLabel";
    long mins = (long)[_highScore integerForKey:@"timerMin"];
    long secs = (long)[_highScore integerForKey:@"timerSecs"];
    if(mins > 0 && secs < 10)
        highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld:0%ld", mins, secs];
    else
        highScoreLabel.text = [NSString stringWithFormat:@"High Score: %ld:%ld", mins, secs];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        highScoreLabel.fontSize = 45;
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
    }else{
        highScoreLabel.fontSize = 16;
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 50);
    }
    [self addChild:highScoreLabel];
    
       // Back
    SKLabelNode *backLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    backLabel.name = @"backLabelNode";
    backLabel.text = @"Tap anywhere to go back";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        backLabel.fontSize = 20;
        backLabel.position = CGPointMake(CGRectGetMidX(self.frame), 100);
    }
    else {
        backLabel.fontSize = 16;
        backLabel.position = CGPointMake(CGRectGetMidX(self.frame), 50);
    }
    [self addChild:backLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    SKScene *titleScene = [[TitleScene alloc] initWithSize:self.size];
    
    [self.view presentScene:titleScene];
}


@end
