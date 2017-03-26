//
//  Defaults.h
//  ProgressWall
//
//  Created by Alex Ling on 27/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface Defaults : NSObject

+ (NSColor *)getBackgroundColor;
+ (void)setBackgroundColor: (NSColor *) color;

+ (NSColor *)getTextColor;
+ (void)setTextColor: (NSColor *) color;

@end
