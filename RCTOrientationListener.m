//
//  RCTOrientationListener.m
//
//  Created by Ken Wheeler on 9/9/15.
//  Copyright (c) 2015 Facebook. All rights reserved.
//

#import "RCTOrientationListener.h"
#import <React/RCTBridge.h>

@implementation RCTOrientationListener

@synthesize bridge = _bridge;

- (instancetype)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    }
    return self;

}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{

    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceStr = [currentDevice model];

    // Add this "timeout" inside deviceOrientationDidChange, because the interface orientation isn't updated yet
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1f * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        NSString *orientationStr = [self getOrientationStr:orientation];
        [_bridge.eventDispatcher sendDeviceEventWithName:@"orientationDidChange"
                                                    body:@{@"orientation": orientationStr,@"device": deviceStr}];
    });
}

- (NSString *)getOrientationStr: (UIInterfaceOrientation)orientation {
  NSString *orientationStr;

  switch (orientation) {
    case UIInterfaceOrientationPortrait:
      orientationStr = @"PORTRAIT";
      break;
    case UIInterfaceOrientationPortraitUpsideDown:
      orientationStr = @"PORTRAITUPSIDEDOWN";
      break;
    case UIInterfaceOrientationLandscapeLeft:
    case UIInterfaceOrientationLandscapeRight:
      orientationStr = @"LANDSCAPE";
      break;
    default:
      orientationStr = @"UNKNOWN";
      break;
  }

  return orientationStr;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getOrientation:(RCTResponseSenderBlock)callback)
{

    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceStr = [currentDevice model];

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    NSString *orientationStr = [self getOrientationStr:orientation];

    NSArray *orientationArray = @[orientationStr, deviceStr];
    callback(orientationArray);
}

@end
