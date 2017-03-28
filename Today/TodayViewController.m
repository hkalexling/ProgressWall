//
//  TodayViewController.m
//  Today
//
//  Created by Alex Ling on 28/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#define kFull @"▓"
#define kEmpty @"░"
#define kBlockNumber 15

@interface TodayViewController () <NCWidgetProviding>

@property (weak) IBOutlet NSTextFieldCell *label;

@end

@implementation TodayViewController

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult result))completionHandler {
	
	NSString *progressStr = [Utility fullProgressString];
	_label.stringValue = progressStr;
	
	completionHandler(NCUpdateResultNoData);
}

@end

