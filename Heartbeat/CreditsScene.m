//
//  CreditsScene.m
//  Heartbeat
//
//  Created by Steven Shing on 5/15/14.
//  Copyright (c) 2014 Steven Shing. All rights reserved.
//

#import "CreditsScene.h"
#import "TitleScene.h"

@implementation CreditsScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor blackColor];
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            bg.xScale = 0.9;
            bg.yScale = 1.2;
        }
        [self addChild: bg];
        [self createSceneContents];
    }
    return self;
}

-(void)createSceneContents{
    //  Credits Title
    SKLabelNode *creditsLabel = [SKLabelNode labelNodeWithFontNamed:@"Lifeline"];
    creditsLabel.name = @"creditsLabelNode";
    creditsLabel.text = @"Credits";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        creditsLabel.fontSize = 80;
        creditsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 400);
    }
    else {
        creditsLabel.fontSize = 40;
        creditsLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 200);
    }
    [self addChild:creditsLabel];
    
    // Code
    SKLabelNode *codeLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    codeLabel.name = @"codeLabelNode";
    codeLabel.text = @"Code";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        codeLabel.fontSize = 60;
        codeLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 300);
    }
    else {
        codeLabel.fontSize = 30;
        codeLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 150);
    }
    [self addChild:codeLabel];
    
    SKLabelNode *everettLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    everettLabel.name = @"everettLabelNode";
    everettLabel.text = @"Everett Leo";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        everettLabel.fontSize = 30;
        everettLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 240);
    }
    else {
        everettLabel.fontSize = 18;
        everettLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 120);
    }
    [self addChild:everettLabel];
    
    SKLabelNode *stevenLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    stevenLabel.name = @"stevenLabelNode";
    stevenLabel.text = @"Steven Shing";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        stevenLabel.fontSize = 30;
        stevenLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 190);
    }
    else {
        stevenLabel.fontSize = 18;
        stevenLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 95);
    }
    [self addChild:stevenLabel];
    
    // Art
    SKLabelNode *artistLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    artistLabel.name = @"artistLabelNode";
    artistLabel.text = @"Art";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        artistLabel.fontSize = 60;
        artistLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 90);
    }
    else {
        artistLabel.fontSize = 30;
        artistLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 45);
    }
    [self addChild:artistLabel];
    
    SKLabelNode *stevenLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    stevenLabel2.name = @"steven2LabelNode";
    stevenLabel2.text = @"Steven Shing";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        stevenLabel2.fontSize = 30;
        stevenLabel2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 30);
    }
    else {
        stevenLabel2.fontSize = 18;
        stevenLabel2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + 15);
    }
    [self addChild:stevenLabel2];
    
    // Sound
    SKLabelNode *soundLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    soundLabel.name = @"soundLabelNode";
    soundLabel.text = @"Sound";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        soundLabel.fontSize = 60;
        soundLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 70);
    }
    else {
        soundLabel.fontSize = 30;
        soundLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 35);
    }
    [self addChild:soundLabel];
    
    SKLabelNode *soundsLabel1 = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    soundsLabel1.name = @"soundsLabel1Node";
    soundsLabel1.text = @"Freesound.org: noisecollector, audionautics";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        soundsLabel1.fontSize = 30;
        soundsLabel1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 130);
    }
    else {
        soundsLabel1.fontSize = 18;
        soundsLabel1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 65);
    }
    [self addChild:soundsLabel1];
    
    SKLabelNode *soundsLabel2 = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    soundsLabel2.name = @"soundsLabel2Node";
    soundsLabel2.text = @"rdholder__2dogsound-player, jobro";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        soundsLabel2.fontSize = 30;
        soundsLabel2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 170);
    }
    else {
        soundsLabel2.fontSize = 18;
        soundsLabel2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 85);
    }
    [self addChild:soundsLabel2];
    
    SKLabelNode *soundsLabel3 = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    soundsLabel3.name = @"soundsLabel3Node";
    soundsLabel3.text = @"Playonloop: Filippo Vicarelli";
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        soundsLabel3.fontSize = 30;
        soundsLabel3.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 230);
    }
    else {
        soundsLabel3.fontSize = 18;
        soundsLabel3.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) - 115);
    }
    [self addChild:soundsLabel3];
    
    
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
