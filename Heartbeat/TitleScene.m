//
//  TitleScene.m
//  Heartbeat
//
//  Created by Steven Shing on 5/15/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "TitleScene.h"
#import "DataStore.h"
#import "GameScene.h"
#import "InstructionsScene.h"
#import "CreditsScene.h"

//static float const kParticleBirthRateDefault = 0.5;

@implementation TitleScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        bg.name = @"bg";
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            bg.xScale = 0.92;
            bg.yScale = 1.20;
        }
        [self addChild: bg];
        [self createSceneContents];
    }
    return self;
}

-(void)createSceneContents{
    // particles
    SKTexture *cell = [SKTexture textureWithImageNamed:@"infectedRedBloodCell.png"];
    
    NSString *particlePath = [[NSBundle mainBundle] pathForResource:@"CellParticle" ofType:@"sks"];
    SKEmitterNode *cells = [NSKeyedUnarchiver unarchiveObjectWithFile:particlePath];
    cells.particleTexture = cell;
    cells.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height + 30);
    cells.particlePositionRange = CGVectorMake(self.frame.size.width - 120, 5);
    [self addChild:cells];
    
    // heart rate label
    SKLabelNode *heartRateLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    heartRateLabel.name = @"heartRateLabelNode";
    heartRateLabel.text = [NSString stringWithFormat:@"Heartrate: %d", [DataStore sharedStore].heartRate];
    heartRateLabel.horizontalAlignmentMode = 2; // position from the right
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        heartRateLabel.fontSize = 28;
        heartRateLabel.position = CGPointMake(self.frame.size.width - 35, self.frame.size.height - 54);
    }
    else {
        heartRateLabel.fontSize = 18;
        heartRateLabel.position = CGPointMake(self.frame.size.width - 30, self.frame.size.height - 32);
    }
    [self addChild:heartRateLabel];
    
    // the title
    SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    titleLabel.name = @"titleLabelNode";
    titleLabel.text = @"Heartbeat";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        titleLabel.fontSize = 80;
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    }
    else {
        titleLabel.fontSize = 40;
        titleLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 100);
    }
    [self addChild:titleLabel];
    
    // add the buttons
    [self addChild:[self playButton]];
    [self addChild:[self instructionButton]];
    [self addChild:[self creditsButton]];
    
}

-(SKLabelNode *)playButton {
    SKLabelNode *playButtonNode = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    playButtonNode.text = @"Play";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        playButtonNode.fontSize = 54;
    }
    else {
        playButtonNode.fontSize = 28;
    }
    playButtonNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    playButtonNode.name = @"playButtonNode";
    return playButtonNode;
}

-(SKLabelNode *)instructionButton {
    SKLabelNode *instructionButtonNode = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    instructionButtonNode.text = @"Instructions";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        instructionButtonNode.fontSize = 54;
        instructionButtonNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
    }
    else {
        instructionButtonNode.fontSize = 28;
        instructionButtonNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 50);
    }
    instructionButtonNode.name = @"instructionButtonNode";
    return instructionButtonNode;
}

-(SKLabelNode *)creditsButton {
    SKLabelNode *creditsButtonNode = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    creditsButtonNode.text = @"Credits";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        creditsButtonNode.fontSize = 54;
        creditsButtonNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 200);
    }
    else {
        creditsButtonNode.fontSize = 28;
        creditsButtonNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 100);
    }
    creditsButtonNode.name = @"creditsButtonNode";
    return creditsButtonNode;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInNode:self];
    SKNode *playButton = [self childNodeWithName:@"playButtonNode"];
    SKNode *instructionsButton = [self childNodeWithName:@"instructionButtonNode"];
    SKNode *creditsButton = [self childNodeWithName:@"creditsButtonNode"];
    
    if(CGRectContainsPoint(playButton.frame, touchPoint)) {
        [self notifyStartGame];
    }
    
    if(CGRectContainsPoint(instructionsButton.frame, touchPoint)) {
        SKScene *instructionsScene = [[InstructionsScene alloc] initWithSize:self.size];
        
        [self.view presentScene:instructionsScene];
    }
    
    if(CGRectContainsPoint(creditsButton.frame, touchPoint)) {
        SKScene *creditsScene = [[CreditsScene alloc] initWithSize:self.size];
        
        [self.view presentScene:creditsScene];
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    SKLabelNode *heartRateLabel = (SKLabelNode*)[self childNodeWithName:@"heartRateLabelNode"];
    heartRateLabel.text =[NSString stringWithFormat:@"Heartrate: %d", [DataStore sharedStore].heartRate];
    
    /*
    SKSpriteNode *bg = (SKSpriteNode*)[self childNodeWithName:@"bg"];
    float scaleBg;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        scaleBg = 0.92 + ((float)[DataStore sharedStore].heartRate - 85.0)/100.0;
    } else {
        scaleBg = 1.0 + ((float)[DataStore sharedStore].heartRate - 85.0)/100.0;
    }
    SKAction *scaleX = [SKAction scaleXTo:scaleBg duration:.5];
    [bg runAction:scaleX withKey:@"scaleBg"];*/
}


- (void)notifyStartGame{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // wrap a Boolean into an NSNumber object using literals syntax
    NSDictionary *dict = @{@"startGame":@1, @"currScene":self};
    
    // "publish" notification
    [notificationCenter postNotificationName:kNotificationStartGame object:self userInfo:dict];
}

@end
