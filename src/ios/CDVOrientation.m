/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

#import "CDVOrientation.h"
#import <Cordova/CDVViewController.h>
#import <objc/message.h>

@implementation CDVOrientation

- (void)screenOrientation:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *pluginResult;
    NSInteger orientationMask = [[command argumentAtIndex:0] integerValue];
    CDVViewController *vc = (CDVViewController *)self.viewController;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    if (orientationMask & 1) {
        [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortrait]];
    }
    
    if (orientationMask & 2) {
        [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown]];
    }
    
    if (orientationMask & 4) {
        [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight]];
    }
    
    if (orientationMask & 8) {
        [result addObject:[NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft]];
    }
    
    SEL selector = NSSelectorFromString(@"setSupportedOrientations:");
    
    if ([vc respondsToSelector:selector]) {
        if ([UIDevice currentDevice]) {
            UIInterfaceOrientation deviceOrientation = [UIApplication sharedApplication].statusBarOrientation;
            UIInterfaceOrientation orientation = deviceOrientation;
            
            if (orientationMask != 15) {
                if (orientationMask == 8 || (orientationMask == 12 && !UIInterfaceOrientationIsLandscape(deviceOrientation))) {
                    orientation = UIInterfaceOrientationLandscapeLeft;
                } else if (orientationMask == 4) {
                    orientation = UIInterfaceOrientationLandscapeRight;
                } else if (orientationMask == 1 || (orientationMask == 3 && !UIInterfaceOrientationIsPortrait(deviceOrientation))) {
                    orientation = UIInterfaceOrientationPortrait;
                } else if (orientationMask == 2) {
                    orientation = UIInterfaceOrientationPortraitUpsideDown;
                }
            }
            
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInt:(int)orientation] forKey:@"orientation"];
            
            ((void (*)(CDVViewController *, SEL, NSMutableArray *))objc_msgSend)(vc, selector, result);
            [UINavigationController attemptRotationToDeviceOrientation];
        }
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_INVALID_ACTION messageAsString:@"Error calling to set supported orientations"];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
