//
//  AppDelegate.m
//  ProgressWall
//
//  Created by Alex Ling on 26/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import "AppDelegate.h"

#define TICK NSDate *startTime = [NSDate date]
#define TOCK NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

@interface AppDelegate ()

@end

@implementation AppDelegate {
	NSStatusItem *item;
	NSWindowController *preferenceWC;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	item.button.image = [NSImage imageNamed:@"status"];
	
	NSMenu *menu = [NSMenu new];
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Preference" action:@selector(preference) keyEquivalent:@","]];
	[menu addItem:[NSMenuItem separatorItem]];
	[menu addItem:[[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quit) keyEquivalent:@"q"]];
	
	item.menu = menu;
	
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(workspaceChanged:) name:NSWorkspaceActiveSpaceDidChangeNotification object:[NSWorkspace sharedWorkspace]];
	
	[self workspaceChanged:nil];
}

- (void)preference {
	preferenceWC = [[NSStoryboard storyboardWithName:@"Main" bundle:nil] instantiateControllerWithIdentifier:@"preferenceWindowController"];
	[preferenceWC showWindow:self];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)quit {
	exit(0);
}

- (void)workspaceChanged: (NSNotification *)notification{
	void (^errorHandler)(NSError *error) = ^(NSError *error){
		NSLog(@"error: %@", error);
	};
	void (^completedHandler)() = ^{
		NSLog(@"completed");
	};
	
	[[[Utility setWallpaper]
		subscribeOn:[RACScheduler mainThreadScheduler]]
	 subscribeError:errorHandler completed:completedHandler];
}

@end
