//
//  ViewController.m
//  Heartbeat
//
//  Created by Student on 5/7/14.
//  Copyright (c) 2014 Student. All rights reserved.
//

#import "ViewController.h"
#import "DataStore.h"
#import "TitleScene.h"
#import "GameScene.h"

// START CATEGORY
// This category is only here so we can print out a string for debugging
// rep of a CBUUID
// http://stackoverflow.com/questions/13275859/how-to-turn-cbuuid-into-string
// iOS 7.1 has CBUUID.UUIDString so you don't need this
@interface CBUUID (StringExtraction)

- (NSString *)representativeString;

@end

@implementation CBUUID (StringExtraction)

- (NSString *)representativeString;
{
    NSData *data = [self data];
    
    NSUInteger bytesToConvert = [data length];
    const unsigned char *uuidBytes = [data bytes];
    NSMutableString *outputString = [NSMutableString stringWithCapacity:16];
    
    for (NSUInteger currentByteIndex = 0; currentByteIndex < bytesToConvert; currentByteIndex++)
    {
        switch (currentByteIndex)
        {
            case 3:
            case 5:
            case 7:
            case 9:[outputString appendFormat:@"%02x-", uuidBytes[currentByteIndex]]; break;
            default:[outputString appendFormat:@"%02x", uuidBytes[currentByteIndex]];
        }
        
    }
    
    return outputString;
}

@end
// END CATEGORY

#define HEART_RATE_SERVICE_UUID [CBUUID UUIDWithString:@"180D"]
#define HEART_RATE_CHAR_UUID [CBUUID UUIDWithString:@"2A37"]

@interface ViewController ()
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableArray *heartRatePeripherals;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@end

@implementation ViewController {
    SKScene *_scene;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // play the bg
    [self playBG];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate: self queue: nil];
    _heartRatePeripherals = [NSMutableArray array];
    
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    // Create and configure the scene.
    _scene = [TitleScene sceneWithSize:skView.bounds.size];
    _scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:_scene];
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self) {
        // register for kNotificationGameDidEnd notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotificationStartGame:)
                                                     name:kNotificationStartGame
                                                   object:_scene];
        // register for kNotificationGameOver notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotificationGameOver:)
                                                     name:kNotificationGameOver
                                                   object:_scene];
        // register for kNotificationGameOver notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleNotificationHeartRateChange:)
                                                     name:kNotificationHeartRateChange
                                                   object:_scene];

    }
    return self;
}

#pragma mark - CBCentralManager delegate methods
// first callback we get after creating _centralManager
// start scanning for devices that have the heart rate service
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn){
        // pass in array of services to scan for
        [self.centralManager scanForPeripheralsWithServices: @[HEART_RATE_SERVICE_UUID] options:nil];
        NSLog(@"Scanning for peripherals");
    } else {
        [self.heartRatePeripherals removeAllObjects];
        NSLog(@"Hey! Bluetooth is powered off!");
    }
}

// when we find a device didDiscoverPeripheral is called

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    // add new peripherals to the list, then try to connect
    NSLog(@"didDiscoverPeripheral");
    if(![self.heartRatePeripherals containsObject: peripheral]){
        [self.heartRatePeripherals addObject: peripheral];
        [self.centralManager connectPeripheral: peripheral options: nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didFailToConnectPeripheral %@ (%@)", peripheral, error);
    [self.heartRatePeripherals removeAllObjects];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"didDisconnectPeripheral peripheral %@ (%@)", peripheral, error);
    [self.heartRatePeripherals removeAllObjects];
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral");
    peripheral.delegate = self;
    [peripheral discoverServices: @[HEART_RATE_SERVICE_UUID]];
    
}

#pragma mark - CBPeripheral methods
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"didDiscoverServices");
    if(! error){
        for (CBService *service in peripheral.services){
            NSLog(@"Service = %@",[service.UUID representativeString]);
            if([service.UUID isEqual:HEART_RATE_SERVICE_UUID]){
                
                NSLog(@"service.UUID == HEART_RATE_SERVICE_UUID");
                // discover heart rate characteristic
                [peripheral discoverCharacteristics: @[HEART_RATE_CHAR_UUID] forService:service];
                return;
            }
        }
    }
    [self.centralManager cancelPeripheralConnection: peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if(!error){
        for(CBCharacteristic *characteristic in service.characteristics){
            if([characteristic.UUID isEqual: HEART_RATE_CHAR_UUID]){
                [peripheral setNotifyValue: YES forCharacteristic: characteristic];
                return;
            }
        }
    }
    [self.centralManager cancelPeripheralConnection: peripheral];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(error){
        NSLog(@"Failed to subscribe to peripheral %@ (%@)",peripheral,error);
        [self.centralManager cancelPeripheralConnection: peripheral];
        return;
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if(characteristic.value.length >= 2){
        uint8_t *bytes = (uint8_t *)[characteristic.value bytes];
        uint16_t heartrate = (bytes[0] & 0x1) ? * (uint16_t *)&bytes[1] : bytes[1];
        [DataStore sharedStore].heartRate = heartrate;
        //NSLog(@"found heartrate of %d", heartrate );
    }
}


#pragma mark - MediaPicker

- (void)playPause {
    if([DataStore sharedStore].isPlaying) [self.audioPlayer pause];
    if(![DataStore sharedStore].isPlaying) [self.audioPlayer play];
    [DataStore sharedStore].isPlaying = ![DataStore sharedStore].isPlaying;
}

- (void)playURL:(NSURL*)url {
    if ([DataStore sharedStore].isPlaying) {
        [self playPause]; // Pause the previous audio player
    }
    
    // play the song in the url
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    // loop infinitely
    [_audioPlayer setNumberOfLoops:-1];
    // playback speed that varies depending on heartrate
    _audioPlayer.enableRate = YES;
    _audioPlayer.rate = 1.0;
    
    [self playPause];
}

- (void)playBG {
    if ([DataStore sharedStore].isPlaying) {
        [self playPause]; // Pause the previous audio player
    }
    
    // play the song in the url
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"bg" ofType:@"wav"];
    NSURL *soundURL = [NSURL fileURLWithPath:soundPath];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundURL error:nil];
    // loop infinitely
    [_audioPlayer setNumberOfLoops:-1];
    // playback speed that varies depending on heartrate
    _audioPlayer.enableRate = YES;
    _audioPlayer.rate = 1.0;
    
    [self playPause];
}

// pick a song by calling a MPMediaPickerController
- (void)pickSong {
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [picker setDelegate:self];
    picker.allowsPickingMultipleItems = NO;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    // dismiss the picker
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // get the first selected item (there is only one for this app)
    MPMediaItem *item = [[mediaItemCollection items] objectAtIndex:0];
    //NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    
    SKScene *gameScene = [[GameScene alloc] initWithSize:_scene.size];
    
    [_scene.view presentScene:gameScene];
    
    
    // pass the URL to playURL:, defined earlier in this file
    [self playURL:url];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Handle Notifications

// handle reading the notifcation
- (void)handleNotificationStartGame:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSNumber *num = userInfo[@"startGame"];
    _scene = userInfo[@"currScene"];
    
    if([num boolValue]) {
        [self pickSong];
    }
}

// handle reading the notification for gameover
- (void)handleNotificationGameOver:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSNumber *num = userInfo[@"gameOver"];
    
    if([num boolValue]) {
        [self playBG];
    }
}

// handle reading a change in heartrate
- (void)handleNotificationHeartRateChange:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    
    NSNumber *num = userInfo[@"heartRate"];
    
    int hr = [num intValue];
    
    float changeRate = ((float)hr - 85.0)/100.0;
    
    if(hr > 0) _audioPlayer.rate = 1.0 + changeRate;
}

#pragma mark - Device Settings

- (BOOL)shouldAutorotate
{
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
