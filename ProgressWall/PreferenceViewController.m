//
//  PreferenceViewController.m
//  ProgressWall
//
//  Created by Alex Ling on 27/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import "PreferenceViewController.h"

#define kGitHubURL @"https://github.com/hkalexling/ProgressWall"

@interface PreferenceViewController ()

@property (weak) IBOutlet NSColorWell *backgroundColorWell;
@property (weak) IBOutlet NSColorWell *textColorWell;

@end

@implementation PreferenceViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	_backgroundColorWell.color = [Defaults getBackgroundColor];
	_textColorWell.color = [Defaults getTextColor];
}

- (void)regenerate {
	[[[Utility setWallpaper]
	 subscribeOn:[RACScheduler mainThreadScheduler]]
	 subscribeError:^(NSError * _Nullable error) {
		 NSLog(@"error: %@", error);
	 } completed:^{
		 NSLog(@"regeneration completed");
	 }];
}

- (IBAction)backgroundColorSet:(NSColorWell *)sender {
	[Defaults setBackgroundColor:sender.color];
	[self regenerate];
}

- (IBAction)textColorSet:(NSColorWell *)sender {
	[Defaults setTextColor:sender.color];
	[self regenerate];
}

- (IBAction)githubBtnTapped:(NSButton *)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:kGitHubURL]];
}

- (IBAction)folderBtnTapped:(NSButton *)sender {
	[[NSWorkspace sharedWorkspace] openFile:[Utility supportPath]];
}

@end
