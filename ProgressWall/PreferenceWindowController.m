//
//  PreferenceWindowController.m
//  ProgressWall
//
//  Created by Alex Ling on 27/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import "PreferenceWindowController.h"

@interface PreferenceWindowController ()

@end

@implementation PreferenceWindowController

- (void)windowDidLoad {
	[super windowDidLoad];
	
	self.window.title = @"";
	self.window.titlebarAppearsTransparent = YES;
	self.window.movableByWindowBackground = YES;
	self.window.backgroundColor = [NSColor colorWithRed:74.0/255 green:205.0/255 blue:47.0/255 alpha:1];
}

@end
