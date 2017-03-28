//
//  Utility.h
//  ProgressWall
//
//  Created by Alex Ling on 28/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import "Defaults.h"

@interface Utility : NSObject

+ (RACSignal *)setWallpaper;
+ (NSString *) supportPath;
+ (NSString *)fullProgressString;

@end
