//
//  Defaults.m
//  ProgressWall
//
//  Created by Alex Ling on 27/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import "Defaults.h"

#define kBackgroundColorKey @"backgroundColor"
#define kTextColorKey @"textColor"

@implementation Defaults

+ (NSColor *)getBackgroundColor {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kBackgroundColorKey]){
		NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kBackgroundColorKey];
		return (NSColor *)[NSUnarchiver unarchiveObjectWithData:data];
	}
	return [NSColor blackColor];
}

+ (void)setBackgroundColor:(NSColor *)color {
	NSData *data = [NSArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:kBackgroundColorKey];
}

+ (NSColor *)getTextColor {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:kTextColorKey]){
		NSData *data = [[NSUserDefaults standardUserDefaults] dataForKey:kTextColorKey];
		return (NSColor *)[NSUnarchiver unarchiveObjectWithData:data];
	}
	return [NSColor whiteColor];
}

+ (void)setTextColor:(NSColor *)color {
	NSData *data = [NSArchiver archivedDataWithRootObject:color];
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:kTextColorKey];
}

@end
