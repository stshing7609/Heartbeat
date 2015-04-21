//
//  GameScene.m
//  Heartbeat
//
//  Created by Everett Leo on 5/7/14.
//  Copyright (c) 2014 Everett Leo. All rights reserved.
//

#import "GameScene.h"
#import "DataStore.h"
#import "GameOverScene.h"
#import "SoundBuddy.h"

static float const kMinFPS = 12.0;
static float const kMaxFPS = 60.0;
static float const kMaxPlayerSpeed = 500.0;
static float const kXdeadZone = 0.03;
static int const kMaxNumEnemies = 40;
static int const kEnemyBaseMoveDuration = 100;
static int const kPillEffectDuration = 600; // The effect of the pill lasts for 10 seconds

static NSString * const kImageTest = @"Spaceship.png";
static NSString * const kImagePlayer = @"redBloodCell.png";
static NSString * const kImageEnemy1 = @"infectedRedBloodCell.png";
static NSString * const kImageEnemy2 = @"infectedRedBloodCell2.png";
static NSString * const kImagePill = @"Pill.png";
static NSString * const kImageHeart = @"Heart.png";

@implementation GameScene{
    // heart rates and accel numbers
    int _heartRate;
    int _robotHeartRate;
    double _accelX;
    double _accelY;
    CMMotionManager *_motionManager;
    
    double _lastTime;
    double _timeSinceLastSecondWentBy;
    
    // enemies
    NSMutableArray *_enemies;
    int _indexOfNextEnemy;
    int _nextEnemySpawn;
    int _enemySpeedModifier;
    
    // player is hit and lives
    BOOL _isBlinking;
    int _lives;
    
    // spawning extra lives
    int _heartSpawnRate;
    int _heartSpawnModifier;
    int _heartXVelocity;
    int _heartYVelocity;
    
    // spawning pills that slow down the blood flow
    // also managing how long the effect lasts
    int _pillSpawnRate;
    float _moveDurationModifier;
    int _pillTimer;
    BOOL _pillInEffect;
    
    // score stuff
    int _timerSecs;
    int _timerMin;
    int _timerTotal;
    int _timerDt;
    int _bestTime;
    NSUserDefaults *_highscore;
    
    // Sound
    SoundBuddy *_soundBuddy;
}

-(id)initWithSize:(CGSize)size{
    if(self = [super initWithSize:size]){
        self.backgroundColor = [SKColor blackColor];
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"bg.png"];
        bg.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        bg.alpha = 0.6;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            bg.xScale = 0.92;
            bg.yScale = 1.22;
        }
        [self addChild: bg];
        
        _soundBuddy = [[SoundBuddy alloc] init];
        
        _heartRate = [DataStore sharedStore].heartRate;
        
        [self createSceneContents];
        
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.accelerometerUpdateInterval = .2;
        [self startMonitoringAccel];
    }
    return self;
}

-(void)createSceneContents{
    // heartrate label
    SKLabelNode *heartRateLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    heartRateLabel.name = @"heartRateLabelNode";
    heartRateLabel.text = [NSString stringWithFormat:@"Heartrate: %d", _heartRate];
    heartRateLabel.horizontalAlignmentMode = 2; // position from the right
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        heartRateLabel.fontSize = 28;
        heartRateLabel.position = CGPointMake(self.frame.size.width - 35, self.frame.size.height - 54);
    }
    else {
        heartRateLabel.fontSize = 20;
        heartRateLabel.position = CGPointMake(self.frame.size.width - 30, self.frame.size.height - 32);
    }
    heartRateLabel.zPosition = 0.5;
    [self addChild:heartRateLabel];
    
    // set the _robotHeartRate to a random number between average heartrates
    _robotHeartRate = (int)[self randomValueBetween:75.0 andValue:120.0];
    
    // lives label
    _lives = 4;
    SKLabelNode *livesLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    livesLabel.name = @"livesLabel";
    livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        livesLabel.fontSize = 28;
        livesLabel.position = CGPointMake(80, self.frame.size.height - 54);
    } else {
        livesLabel.fontSize = 20;
        livesLabel.position = CGPointMake(80, self.frame.size.height - 32);
    }
    livesLabel.zPosition = 0.5;
    [self addChild:livesLabel];
    
    // timer in mins and secs
    SKLabelNode *timerLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    timerLabel.name = @"timerLabel";
    timerLabel.text = [NSString stringWithFormat:@"00:00"];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        timerLabel.fontSize = 28;
        timerLabel.position = CGPointMake(50, self.frame.size.height - 84);
    }else{
        timerLabel.fontSize = 20;
        timerLabel.position = CGPointMake(50, self.frame.size.height - 62);
    }
    timerLabel.zPosition = 0.5;
    [self addChild:timerLabel];
    
    // player
    SKSpriteNode *player = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kImagePlayer]];
    player.name = @"player";
    player.scale = 0.7;
    player.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height / 10);
    [self addChild: player];
    
    _isBlinking = false;
    
    // enemies
    _enemies = [[NSMutableArray alloc] initWithCapacity:kMaxNumEnemies];
    _indexOfNextEnemy = 0;
    _enemySpeedModifier = 0;
    
    // make the texture array for the enemy sprites
    SKTexture* f1 = [SKTexture textureWithImageNamed:kImageEnemy1];
    SKTexture* f2 = [SKTexture textureWithImageNamed:kImageEnemy2];
    NSArray *infectedCellTextures = @[f1, f2];
    
    // start with all of the enemies hidden at the top of the screen
    //they only become unhidden when they are "spawned" and start moving
    for(int i = 0; i < kMaxNumEnemies; i++){
        SKSpriteNode* enemy = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kImageEnemy1]];
        enemy.hidden = YES;
        enemy.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height);
        //enemy.scale = 0.7;
        
        SKAction *infectedCellPulse = [SKAction animateWithTextures:infectedCellTextures timePerFrame:0.5];
        SKAction *repeatPulse = [SKAction repeatActionForever:infectedCellPulse];
        
        [enemy runAction:repeatPulse];
        
        float spinRate = [self randomValueBetween:1.0 andValue:1.4];
        float angleChange = [self randomValueBetween:0.2 andValue:0.7];
        SKAction* rotate = [SKAction rotateByAngle:angleChange duration:spinRate];
        SKAction* repeatRotate = [SKAction repeatActionForever:rotate];
        [enemy runAction:repeatRotate withKey:@"pillRotating"];
        
        [_enemies addObject:enemy];
        [self addChild:enemy];
    }
    
    // extra life heart
    SKSpriteNode *heart = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kImageHeart]];
    heart.name = @"heart";
    heart.hidden = YES;
    heart.scale = 0.7;
    heart.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height);
    [self addChild:heart];
    _heartSpawnRate = 60 + CACurrentMediaTime();
    _heartXVelocity = 0;
    _heartYVelocity = -1;
    
    // slowdown pill
    SKSpriteNode *pill = [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImageNamed:kImagePill]];
    pill.name = @"pill";
    pill.hidden = YES;
    pill.scale = 0.7;
    pill.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height);
    [self addChild:pill];
    _pillSpawnRate = CACurrentMediaTime() + 20;
    _moveDurationModifier = 0.0;
    
    // instantiate timers and _highscore
    _timerDt = 0;
    _timerTotal = 0;
    _timerSecs = 0;
    _timerMin = 0;
    _highscore = [[NSUserDefaults alloc] init];
    _bestTime = ([_highscore integerForKey:@"timerMin"]*60) + [_highscore integerForKey:@"timerSecs"];
    
    _pillTimer = 0;
    _pillInEffect = NO;
}

#pragma mark - Accelerometer

- (void)startMonitoringAccel{
    if (_motionManager.accelerometerAvailable) {
        [_motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                             withHandler:^(CMAccelerometerData  *accelerometerData, NSError *error) {
                                                 [self captureAccelData:accelerometerData.acceleration];
                                                 if(error){
                                                     NSLog(@"%@", error);
                                                 }
                                             }];
        
        NSLog(@"accelerometer updates on...");
    }
}

- (void)stopMonitoringAccel{
    if (_motionManager.accelerometerAvailable && _motionManager.accelerometerActive) {
        [_motionManager stopAccelerometerUpdates];
        NSLog(@"accelerometer updates off...");
    }
}


-(void)captureAccelData:(CMAcceleration)acceleration{
    //NSLog(@"x=%f, y=%f, z=%f",acceleration.x,acceleration.y,acceleration.z);
    
    _accelX = acceleration.x;
    
    
    if (fabs(_accelX) <= kXdeadZone) _accelX = 0.0;
    if (fabs(_accelY) <= kXdeadZone) _accelY = 0.0;
    /*
     Our max _accelY is 0.6
     Our min _accelY is -0.4
     Which means we move up the screen faster than we can move down it
     But that works OK here
     */
}

#pragma mark - Game Loop

-(void)update:(NSTimeInterval)currentTime{
    // update heartRate
    _heartRate = [DataStore sharedStore].heartRate;
    SKLabelNode *heartRateLabel = (SKLabelNode*)[self childNodeWithName:@"heartRateLabelNode"];
    if(_heartRate > 0)
        heartRateLabel.text = [NSString stringWithFormat:@"Heartrate: %d", _heartRate];
    else
        heartRateLabel.text = [NSString stringWithFormat:@"Robot rate: %d", _robotHeartRate];
    
    // update the duration of the pill effect
    if(_pillInEffect) _pillTimer++;
    if(_pillTimer >= kPillEffectDuration) {
        _pillInEffect = NO;
        _pillTimer = 0;
    }
    
    double time = (double)CFAbsoluteTimeGetCurrent();
    float dt = time - _lastTime;
    _lastTime = time;
    
    dt = MAX(dt, 1.0 / kMaxFPS);
    dt = MIN(dt, 1.0 / kMinFPS);
    
    SKSpriteNode *player = (SKSpriteNode*)[self childNodeWithName:@"player"];
    
    float maxX = self.frame.size.width - player.size.width / 2 - 45;
    float minX = player.size.width / 2 + 45;
    float newX = kMaxPlayerSpeed * _accelX * dt;
    
    newX = MIN(MAX(newX + player.position.x, minX), maxX);
    player.position = CGPointMake(newX, player.position.y);
    
    // get the current time first as a double, then as an int
    double currTime = CACurrentMediaTime();
    int now = (int)currTime;
    
    // update the _robotHeartRate
    if(now % 5 == 0) {
        float rand = [self randomValueBetween:-1.0 andValue:1.0];
        
        if(rand > 0){
            _robotHeartRate += 2;
        } else {
            _robotHeartRate -= 2;
        }
        
        if(_robotHeartRate < 75) _robotHeartRate = 75;
        if(_robotHeartRate > 120) _robotHeartRate = 120;
        
        // send the heartRate back to ViewController to update the playback speed
        [self notifyHeartRateChange];
    }
    
    // update the timer
    _timerDt++;
    if(_timerDt >= 60){
        _timerDt = 0;
        _timerTotal++;
        _timerSecs++;
        if(_timerSecs >= 60){
            _timerSecs = 0;
            _timerMin++;
        }
        SKLabelNode *timerLabel = (SKLabelNode*)[self childNodeWithName:@"timerLabel"];
        timerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        // if the timer has at least 1 min and les than 10 seconds, add an extra 0 before the actual seconds
        if(_timerMin > 0 && _timerSecs < 10)
            timerLabel.text = [NSString stringWithFormat:@"%d:0%d", _timerMin, _timerSecs];
        else
            timerLabel.text = [NSString stringWithFormat:@"%d:%d", _timerMin, _timerSecs];
    }
    
    // enemy spawn
    float moveDuration;
    if(currTime > _nextEnemySpawn){
        // speed works inversly - the slower the value, the faster it moves
        // thus the modifier is being subtracted to make the speed smaller
        int speed = kEnemyBaseMoveDuration - _enemySpeedModifier;
        //int speed = kEnemyBaseMoveDuration;
        // do some math with the heart rate
        float modifiedHeartRate;
        if(_heartRate > 0)
            modifiedHeartRate = 100 - _heartRate;
        else
            modifiedHeartRate = 100 - _robotHeartRate;
        moveDuration = (speed + modifiedHeartRate) / 10 + _moveDurationModifier;
        if(!_pillInEffect) _moveDurationModifier = 0.0;
        
        if(moveDuration < 3.0){
            moveDuration = 3.0;
        }
        //NSLog(@"moveDuration: %f", moveDuration);
        
        float lowerSpawnTime = moveDuration / 10.0 + 0.5;
        float upperSpawnTime = moveDuration / 10.0 + 0.8;
        // randomly selects the delay for the next enemy
        float randSecs = [self randomValueBetween:lowerSpawnTime andValue:upperSpawnTime];
        _nextEnemySpawn = randSecs + currTime;
        
        //NSLog(@"randSecs: %f, nextEnemySpawn: %d", randSecs, _nextEnemySpawn);
        
        float randX = [self randomValueBetween:60.0 andValue:self.frame.size.width - 60.0];
        
        // select the next enemy to "awaken"
        SKSpriteNode* enemy = [_enemies objectAtIndex:_indexOfNextEnemy];
        _indexOfNextEnemy++;
        
        //******** Speed up code ********
        float diff = kEnemyBaseMoveDuration - _enemySpeedModifier;
        if(_indexOfNextEnemy % 5 == 0 && diff > 11){
            _enemySpeedModifier += 10;
        } else if(_indexOfNextEnemy % 5 == 0 && diff > 0.3){
            //float diff = kEnemyBaseMoveDuration - _enemySpeedModifier;
            _enemySpeedModifier += (diff / 2);
        }
        
        // if we cannot have have any more enemies on screen reset the counter
        if(_indexOfNextEnemy >= [_enemies count]){
            _indexOfNextEnemy = 0;
        }
        
        //[enemy removeAllActions];
        [enemy removeActionForKey:@"enemyMoving"];
        
        enemy.position = CGPointMake(randX, self.frame.size.height + enemy.frame.size.height / 2);
        enemy.hidden = NO;
        
        CGPoint endLocation = CGPointMake(randX, -enemy.frame.size.height / 2);
        
        SKAction* moveAction = [SKAction moveTo:endLocation duration:moveDuration];
        SKAction* doneAction = [SKAction runBlock:(dispatch_block_t)^(){
            enemy.hidden = YES;
        }];
        
        SKAction* moveInfectedCellWithDone = [SKAction sequence:@[moveAction, doneAction]];
        [enemy runAction:moveInfectedCellWithDone withKey:@"enemyMoving"];
    }
    
    // enemy collisions
    for(SKSpriteNode* enemyCell in [_enemies copy]){
        if(enemyCell.hidden || _isBlinking)
            continue;
        
        if([player intersectsNode:enemyCell]){
            [_soundBuddy playSound:kSoundHit];
            enemyCell.hidden = YES;
            _isBlinking = true;
            _lives--;
            //******** Speed up code ********
            _enemySpeedModifier += 20;
            
            SKLabelNode *livesLabel = (SKLabelNode*)[self childNodeWithName:@"livesLabel"];
            livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
            
            if(_lives <= 0){
                // update the high score
                if(_bestTime == 0 || _timerTotal > _bestTime){
                    [_highscore setInteger:_timerMin forKey:@"timerMin"];
                    [_highscore setInteger:_timerSecs forKey:@"timerSecs"];
                }
                
                [self gameOver];
            }
            
            // blink so that we cannot take damage during this time
            SKAction *blink = [SKAction sequence:@[[SKAction fadeOutWithDuration:0.3],[SKAction fadeInWithDuration:0.3]]];
            SKAction *blinkForTime = [SKAction repeatAction:blink count:4];
            [player runAction:blinkForTime completion:^{
                _isBlinking = false;
            }];
        }
    }
    
    // heart spawn
    SKSpriteNode *heart = (SKSpriteNode*)[self childNodeWithName:@"heart"];
    //NSLog(@"currTime: %f | spawnRate: %d", currTime, _heartSpawnRate);
    if(currTime > _heartSpawnRate){
        if(_lives < 2 && _heartSpawnModifier >= 60){
            _heartSpawnModifier = 30;
        } else {
            _heartSpawnModifier = 60;
        }
        
        _heartSpawnRate = _heartSpawnModifier + currTime;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            heart.position = CGPointMake(self.frame.size.width / 2 - 150, self.frame.size.height + heart.frame.size.height / 2);
        else
            heart.position = CGPointMake(self.frame.size.width / 2, self.frame.size.height + heart.frame.size.height / 2);
        heart.hidden = NO;
    }
    
    // move the heart
    if(!heart.hidden){
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            _heartXVelocity = sin(heart.position.y / 36) * 7;
            //_heartYVelocity = -2;
        }else{
            _heartXVelocity = sin(heart.position.y / 24) * 4;
            //_heartYVelocity = -1;
        }
        _heartYVelocity = -1;
        int heartX = heart.position.x + _heartXVelocity;
        int heartY = heart.position.y + _heartYVelocity;
        heart.position = CGPointMake(heartX, heartY);
        if(heartY < -heart.frame.size.height / 2)
            heart.hidden = YES;
    }
    
    // check collisions deragainst heart
    if([player intersectsNode:heart] && !heart.hidden){
        [_soundBuddy playSound:kSoundHpUp];
        heart.hidden = YES;
        _lives++;
        SKLabelNode *livesLabel = (SKLabelNode*)[self childNodeWithName:@"livesLabel"];
        livesLabel.text = [NSString stringWithFormat:@"Lives: %d", _lives];
    }
    
    
    
    SKSpriteNode* pill = (SKSpriteNode*)[self childNodeWithName:@"pill"];
    // pill spawn
    if(currTime > _pillSpawnRate){
        float randSecs = [self randomValueBetween:45.0 andValue:60.0];
        _pillSpawnRate = randSecs + currTime;
        
        float randX = [self randomValueBetween:45.0 andValue:self.frame.size.width - 45.0];
        
        pill.hidden = NO;
        pill.position = CGPointMake(randX, self.frame.size.height + pill.size.height / 2);
        
        //[pill removeAllActions];
        [pill removeActionForKey:@"pillMoving"];
        CGPoint endLocation = CGPointMake(randX, -pill.frame.size.height / 2);
        
        SKAction* rotate = [SKAction rotateByAngle:0.5 duration:0.8];
        SKAction* repeatRotate = [SKAction repeatActionForever:rotate];
        [pill runAction:repeatRotate withKey:@"pillRotating"];
        
        SKAction* moveAction = [SKAction moveTo:endLocation duration:moveDuration];
        SKAction* doneAction = [SKAction runBlock:(dispatch_block_t)^(){
            pill.hidden = YES;
        }];
        SKAction* movePillWithDone = [SKAction sequence:@[moveAction, doneAction]];
        [pill runAction:movePillWithDone withKey:@"pillMoving"];
    }
    
    // pill collisions
    if([player intersectsNode:pill] && !pill.hidden){
        //NSLog(@"Pill Hit!");
        [_soundBuddy playSound:kSoundPill];
        pill.hidden = YES;
        //_enemySpeedModifier += 30;
        _moveDurationModifier = 3.5;
        _pillInEffect = YES;
    }
}

#pragma mark - Notifications

- (void)gameOver {
    //NSLog(@"High Score: %ld:%ld", (long)[_highscore integerForKey:@"timerMin"], (long)[_highscore integerForKey:@"timerSecs"]);
    [_soundBuddy playSound:kSoundGameOver];
    [self notifyGameOver];
    
    SKScene *gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
    
    [self.view presentScene:gameOverScene];
    
}

- (void)notifyGameOver{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // wrap a Boolean into an NSNumber object using literals syntax
    NSDictionary *dict = @{@"gameOver":@1};
    
    // "publish" notification
    [notificationCenter postNotificationName:kNotificationGameOver object:self userInfo:dict];
}


- (void)notifyHeartRateChange {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    // wrap a Boolean into an NSNumber object using literals syntax
    NSNumber *hr;
    if(_heartRate > 0) hr = @(_heartRate);
    else hr = @(_robotHeartRate);
    NSDictionary *dict = @{@"heartRate":hr};
    
    // "publish" notification
    [notificationCenter postNotificationName:kNotificationHeartRateChange object:self userInfo:dict];
}


#pragma mark - Utilities

-(float)randomValueBetween:(float)low andValue:(float)high{
    return (((float)arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

@end
