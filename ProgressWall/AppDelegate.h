//
//  AppDelegate.h
//  ProgressWall
//
//  Created by Alex Ling on 26/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (RACSignal *)setWallpaper; //regernerate image
- (NSString *)supportPath;

@end

