/* BubbleGun Level Maker - MainController.m
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Betty Lab. All rights reserved. */

#import "MainController.h"
#import "DocumentController.h"
#import <Z/functions/base/Z2DValue.h>

#define kDefaultDocumentXSize 8
#define kDefaultDocumentYSize 11


@implementation MainController


#	pragma mark - Helpers


	- (void) registerDocumentController: (DocumentController *) controller
		{
		NSWindow *window = controller.window;

		[_documentControllers addObject: controller];

		[[NSNotificationCenter defaultCenter]
			addObserver: self
			selector:    @selector(documentWindowDidClose:)
			name:	     NSWindowWillCloseNotification
			object:	     window];

		[controller showWindow: nil];
		}


#	pragma mark - Listeners


	- (void) documentWindowDidClose: (NSNotification *) notification
		{
		NSWindow *window = notification.object;

		[[NSNotificationCenter defaultCenter]
			removeObserver: self
			name:		NSWindowWillCloseNotification
			object:		window];

		[_documentControllers removeObject: window.windowController];
		}


#	pragma mark - NSApplicationDelegate Protocol


	- (void) applicationWillFinishLaunching: (NSNotification *) notification
		{_documentControllers = [[NSMutableArray alloc] init];}


	- (void) applicationDidFinishLaunching: (NSNotification *) notification
		{if (![_documentControllers count]) [self newDocument: self];}


	- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) sender
		{return NO;}


	- (void) applicationWillTerminate: (NSNotification *) notification
		{[_documentControllers release];}


	- (BOOL) applicationShouldOpenUntitledFile: (NSApplication *) sender
		{
		if (![_documentControllers count]) [self newDocument: sender];
		return NO;
		}


	- (void) applicationDidResignActive: (NSNotification *) notification
		{if (![_documentControllers count]) [NSApp terminate: self];}


	- (BOOL) application: (NSApplication *) application
		 openFile:    (NSString      *) filePath
		{
		DocumentController *controller = nil;

		for (DocumentController *controller in _documentControllers)
			{
			NSString *path = controller.filePath;

			if (path && [path isEqualToString: filePath])
				{
				[controller showWindow: nil];
				return NO;
				}
			}

		NSError *error = nil;
		controller = [[DocumentController alloc] initWithFile: filePath error: &error];

		if (!controller)
			{
			[[NSAlert alertWithError: error] runModal];
			return NO;
			}

		[self registerDocumentController: controller];
		[controller release];
		return YES;
		}


#	pragma mark - IBAction


	- (IBAction) openDocument: (id) sender
		{
		NSOpenPanel *panel = [NSOpenPanel openPanel];

		panel.allowedFileTypes = [NSArray arrayWithObject: @"bgl"];

		if ([panel runModal] == NSFileHandlingPanelOKButton)
			[self application: NSApp openFile: panel.URL.path];
		}


	- (IBAction) newDocument: (id) sender
		{
		DocumentController *controller = [[DocumentController alloc]
			initWithFieldSize: z_2d_type(SIZE)(kDefaultDocumentXSize, kDefaultDocumentYSize)];

		[self registerDocumentController: controller];
		[controller release];
		}


@end

// EOF
