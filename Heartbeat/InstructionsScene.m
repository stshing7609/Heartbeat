//
//  InstructionsScene.m
//  Heartbeat
//
//  Created by Steven Shing on 5/15/14.
//  Copyright (c) 2014 Steven Shing. All rights reserved.
//

#import "InstructionsScene.h"
#import "TitleScene.h"

@implementation InstructionsScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        SKSpriteNode *instructions = [SKSpriteNode spriteNodeWithImageNamed:@"instructions.png"];
        instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            instructions.xScale = 0.9;
            instructions.yScale = 1.2;
        }
        [self addChild: instructions];
        [self createSceneContents];
    }
    return self;
}

-(void)createSceneContents{
    SKLabelNode *instructionsLabel = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    instructionsLabel.name = @"instructionsLabelNode";
    instructionsLabel.text = @"Instructions";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        instructionsLabel.fontSize = 80;
        instructionsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 400);
    }
    else {
        instructionsLabel.fontSize = 40;
        instructionsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    }
    [self addChild:instructionsLabel];
    
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
