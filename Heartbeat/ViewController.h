//
//  ViewController.h
//  Heartbeat
//

//  Copyright (c) 2014 Steven Shing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate, MPMediaPickerControllerDelegate>

@end
