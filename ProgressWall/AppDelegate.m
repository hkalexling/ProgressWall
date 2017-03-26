//
//  AppDelegate.m
//  ProgressWall
//
//  Created by Alex Ling on 26/3/2017.
//  Copyright © 2017 Alex Ling. All rights reserved.
//

#import "AppDelegate.h"
#import "Defaults.h"

#define TICK NSDate *startTime = [NSDate date]
#define TOCK NSLog(@"Time: %f", -[startTime timeIntervalSinceNow])

#define kScreenWidth 2880.0
#define kScreenHeight 1800.0
#define kTextWidth kScreenWidth * 0.8

#define kFull @"▓"
#define kEmpty @"░"
#define kBlockNumber 15

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
	
	[[[self setWallpaper]
		subscribeOn:[RACScheduler mainThreadScheduler]]
	 subscribeError:errorHandler completed:completedHandler];
}

#pragma mark - Utility

- (RACSignal *)setWallpaper {
	return [[self imageWithText:[self fullProgressString]] flattenMap:^__kindof RACSignal * _Nullable(NSImage *img) {
		return [[self saveImageToSupport:img] flattenMap:^__kindof RACSignal * _Nullable(NSString *path) {
			return [self setWallpaper:path];
		}];
	}];
}

- (RACSignal *)setWallpaper: (NSString *) path; {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		NSString *thePath = [path copy];

		NSURL *url = [NSURL fileURLWithPath:thePath];
		NSArray *screens = [NSScreen screens];
		for (NSScreen *screen in screens){
			NSError *error;
			[[NSWorkspace sharedWorkspace] setDesktopImageURL:url forScreen:screen options:@{} error:&error];
			if (error){
				[subscriber sendError: error];
			}
		}
		[subscriber sendCompleted];
		
		return nil;
	}];
}

- (RACSignal *)imageWithText: (NSString *) text {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		
		NSImage *img = [[NSImage alloc] initWithSize:NSMakeSize(kScreenWidth, kScreenHeight)];
		NSDictionary *attr = @{
													 NSFontAttributeName: [NSFont fontWithName:@"Avenir" size:120 ],
													 NSForegroundColorAttributeName: [Defaults getTextColor]
													 };
		NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:text attributes:attr];
		CGRect boundRect = [attrStr boundingRectWithSize:CGSizeMake(kTextWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading];
		
		[img lockFocus];
		
		[[Defaults getBackgroundColor] drawSwatchInRect:NSMakeRect(0, 0, kScreenWidth, kScreenHeight)];
		
		
		NSRect rect = NSMakeRect((kScreenWidth - boundRect.size.width)/2, (kScreenHeight - boundRect.size.height)/2, boundRect.size.width, boundRect.size.height);
		[text drawInRect:rect withAttributes:attr];
		
		[img unlockFocus];
		
		[subscriber sendNext:img];
		[subscriber sendCompleted];
		
		return nil;
	}];
}

- (NSString *) supportPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
	NSString *support = [[paths firstObject] stringByAppendingPathComponent:@"com.hkalexling.progress-wall"];
	return support;
}

- (RACSignal *) clearSupportDirectory {
	return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			NSFileManager *manager = [NSFileManager defaultManager];
			NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:[self supportPath]];
			NSError *error;
			
			NSString *file;
			while (file = [enumerator nextObject]) {
				[manager removeItemAtPath:[[self supportPath] stringByAppendingPathComponent:file] error:&error];
			}
			
			dispatch_async(dispatch_get_main_queue(), ^{
				if (error){
					[subscriber sendError:error];
				}
				else{
					[subscriber sendCompleted];
				}
			});
		});
		
		return nil;
	}];
}

- (RACSignal *)saveImageToSupport:(NSImage *)image {
	return [[self clearSupportDirectory] then:^RACSignal * _Nonnull{
		return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
			NSFileManager *manager = [NSFileManager defaultManager];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				BOOL isDir;
				if (![manager fileExistsAtPath:[self supportPath] isDirectory:&isDir]){
					NSError *error;
					[manager createDirectoryAtPath:[self supportPath] withIntermediateDirectories:YES attributes:nil error:&error];
					if (error){
						dispatch_async(dispatch_get_main_queue(), ^{
							[subscriber sendError:error];
						});
					}
				}
				
				NSString *name = [NSString stringWithFormat:@"%@.jpg", @([[NSDate date] timeIntervalSince1970])];
				NSString *imgPath = [[self supportPath] stringByAppendingPathComponent:name];
				
				NSData *imageData = [image TIFFRepresentation];
				NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:imageData];
				NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0] forKey:NSImageCompressionFactor];
				imageData = [rep representationUsingType:NSJPEGFileType properties:imageProps];
				[imageData writeToFile:imgPath atomically:YES];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[subscriber sendNext:imgPath];
					[subscriber sendCompleted];
				});
			});
			
			return nil;
		}];
	}];
}

#pragma mark - Date Utility

- (NSDate *)firstDateOfYear:(NSInteger)year {
	NSDateComponents *dc = [[NSDateComponents alloc] init];
	dc.year = year;
	dc.month = 1;
	dc.day = 1;
	return [[NSCalendar currentCalendar] dateFromComponents:dc];
}

- (NSInteger)numberOfDaysInYear {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSInteger year = [cal component:NSCalendarUnitYear fromDate:[NSDate date]];
	
	NSDate *firstDateOfYear = [self firstDateOfYear:year];
	NSDate *firstDateOfNextYear = [self firstDateOfYear:year + 1];
	
	NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:firstDateOfYear toDate:firstDateOfNextYear options:0];
	return [components day];
}

- (NSInteger)dayInYear {
	NSCalendar *cal = [NSCalendar currentCalendar];
	NSInteger dayInYear = [cal ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitYear forDate:[NSDate date]];
	return dayInYear;
}

- (CGFloat)progress {
	return (CGFloat)[self dayInYear]/(CGFloat)[self numberOfDaysInYear];
}

#pragma mark - Progress Bar Constructors

- (NSString *)progressString {
	return [NSString stringWithFormat:@"%li%%", (long)([self progress] * 100)];
}

- (NSString *)progressBarString {
	NSInteger fullNumber = [self progress] * kBlockNumber;
	NSString *str = @"";
	for (NSUInteger i = 0; i < fullNumber; i++){
		str = [str stringByAppendingString:kFull];
	}
	for (NSUInteger i = 0; i < kBlockNumber - fullNumber; i++){
		str = [str stringByAppendingString:kEmpty];
	}
	return str;
}

- (NSString *)fullProgressString {
	return [NSString stringWithFormat:@"%@ %@", [self progressBarString], [self progressString]];
}

@end
