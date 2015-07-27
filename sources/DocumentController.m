/* BubbleGun Level Maker - DocumentController.m
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "DocumentController.h"
#import <Q/functions/base/Q2DValue.h>
#import <Q/macros/casting.h>

#define kDefaultBubbleRadius 45.0
#define kMinimumWindowWidth  360

#define NS(structure) Q_CAST(Q2D, NSSize, structure)
#define Q( structure) Q_CAST(NSSize, Q2D, structure)


@interface NSWindow (RedCode)

	- (void) animateIntoScreenFrame: (NSRect) screenFrame
		 fromTopCenterToSize:	 (NSSize) size;

@end


@implementation NSWindow (RedCode)

	- (void) animateIntoScreenFrame: (NSRect) screenFrame
		 fromTopCenterToSize:	 (NSSize) size
		{
		NSRect oldFrame = self.frame;

		NSRect newFrame = NSMakeRect
			(oldFrame.origin.x + oldFrame.size.width / 2.0 - size.width / 2.0,
			 oldFrame.origin.y + oldFrame.size.height      - size.height,
			 size.width, size.height);

		if (!NSContainsRect(screenFrame, newFrame))
			{
			if (newFrame.origin.x < screenFrame.origin.x)
				newFrame.origin.x = screenFrame.origin.x;

			else if (NSMaxX(newFrame) > NSMaxX(screenFrame))
				newFrame.origin.x = screenFrame.origin.x + screenFrame.size.width - size.width;

			if (newFrame.origin.y < screenFrame.origin.y)
				newFrame.origin.y = screenFrame.origin.y;

			else if (NSMaxY(newFrame) > NSMaxY(screenFrame))
				newFrame.origin.y = screenFrame.origin.y + screenFrame.size.height - size.height;
			}

		BOOL visible = self.isVisible;
		[self setFrame: newFrame display: visible animate: visible];
		}

@end


@implementation DocumentController


#	pragma mark - Helpers


	- (NSError *) saveAtPath: (NSString *) path
		{
		NSData *data = [_field data];
		NSError *error = nil;

		if (![data writeToFile: path options: NSDataWritingAtomic error: &error])
			return error;

		if (_filepath != path)
			{
			[_filepath release];
			_filepath = [path retain];
			[_title release];
			self.window.title = _title = [[[path lastPathComponent] stringByDeletingPathExtension] retain];
			}

		[self.window setDocumentEdited: NO];
		return nil;
		}


#	pragma mark - Property Accessors

	@synthesize filePath = _filepath;


#	pragma mark - Overwritten


	- (void) dealloc
		{
		[sizeInputWindow release];
		sizeInputWindow = nil;
		[_title release];
		[_field release];
		[_filepath release];
		[super dealloc];
		}


	- (void) windowDidLoad
		{
		NSWindow *window = self.window;
		NSSize fieldSize = _field.frame.size;

		window.title = _title;
		[window setContentSize: fieldSize];
		[window.contentView addSubview: _field];
		[window.toolbar setSelectedItemIdentifier: @"Black"];
		}


#	pragma mark - Public


	- (id) initWithFieldSize: (Q2DSize) size
		{
		if ((self = [super initWithWindowNibName: @"Document"]))
			{
			NSRect fieldFrame;
			fieldFrame.origin = NSZeroPoint;
			fieldFrame.size = [Field sizeToFitFieldOfSize: size bubbleDiameter: kDefaultBubbleRadius];

			_title = [_("Untitled") retain];
			_field = [[Field alloc] initWithFrame: fieldFrame size: size];
			_field.target = self;
			_field.action = @selector(fieldDidChange:);

			[NSBundle loadNibNamed: @"SizeInput" owner: self];

			xSizeTextField.stringValue = [NSString stringWithFormat: @"%lu", (unsigned long)size.x];
			ySizeTextField.stringValue = [NSString stringWithFormat: @"%lu", (unsigned long)size.y];
    			}
    
		return self;
		}


	- (id) initWithFile: (NSString *) filePath
	       error:	     (NSError **) error
		{
		NSData *data = [NSData dataWithContentsOfFile: filePath options: 0 error: error];
		Field *field;

		if (!data) return nil;

		if (!(field = [[Field alloc] initWithFrame: NSMakeRect(0.0, 0.0, 10.0, 10.0) data: data]))
			{
			if (error != NULL) *error = [NSError
				errorWithDomain: @"DocumentControllerError"
				code:		 0
				userInfo:	 [NSDictionary dictionaryWithObjectsAndKeys:
					_("Error.BadDocumentFormat.Description"), NSLocalizedDescriptionKey,
					_("Error.BadDocumentFormat.Reason"),	  NSLocalizedRecoverySuggestionErrorKey,
					nil]];

			[self release];
			return nil;
			}

		if ((self = [super initWithWindowNibName: @"Document"]))
			{
			Q2DSize size = field.size;
			NSRect fieldFrame;
			fieldFrame.origin = NSZeroPoint;
			fieldFrame.size = [Field sizeToFitFieldOfSize: size bubbleDiameter: kDefaultBubbleRadius];

			field.frame = fieldFrame;
			_filepath = [filePath retain];
			_title = [[[filePath lastPathComponent] stringByDeletingPathExtension] retain];
			_field = field;
			_field.target = self;
			_field.action = @selector(fieldDidChange:);

			[NSBundle loadNibNamed: @"SizeInput" owner: self];

			xSizeTextField.stringValue = [NSString stringWithFormat: @"%lu", (unsigned long)size.x];
			ySizeTextField.stringValue = [NSString stringWithFormat: @"%lu", (unsigned long)size.y];
			}

		else [field release];

		return self;
		}


#	pragma mark - NSWindowDelegate Protocol


	- (void) alertDidEnd: (NSAlert *) alert
		 returnCode:  (NSInteger) returnCode
		 contextInfo: (void    *) contextInfo
		{
		if (returnCode == NSAlertDefaultReturn)
			{
			[alert.window orderOut: self];
			_closeWindowAfterSave = YES;
			[self saveDocument: self];
			}

		else if (returnCode == NSAlertAlternateReturn)
			{
			[alert.window orderOut: self];
			[self.window setDocumentEdited: NO];
			[self.window performClose: self];
			}
		}


	- (BOOL) windowShouldClose: (id) sender
		{
		if (![self.window isDocumentEdited]) return YES;

		NSAlert *alert = [NSAlert
			alertWithMessageText:	   [NSString stringWithFormat: _("UnsavedDocument.Header"), _title]
			defaultButton:		   _("Save")
			alternateButton:	   _("DontSave")
			otherButton:		   _("Cancel")
			informativeTextWithFormat: _("UnsavedDocument.Body")];

		[alert	beginSheetModalForWindow: self.window
			modalDelegate:		  self
			didEndSelector:		  @selector(alertDidEnd:returnCode:contextInfo:)
			contextInfo:		  nil];

		return NO;
		}


	- (NSSize) windowWillResize: (NSWindow *) window
		   toSize:	     (NSSize	) size
		{
		Q2D borderSize	     = q_2d_subtract(Q(window.frame.size), Q(((NSView *)window.contentView).bounds.size));
		Q2D maximumFieldSize = q_2d_subtract(Q(window.screen.visibleFrame.size), borderSize);
		Q2D contentSize	     = q_2d_subtract(Q(size), borderSize);
		NSSize fieldSize     = [Field sizeToFitFieldOfSize: _field.size bubbleDiameter: 1.0];

		if (contentSize.y > maximumFieldSize.y) contentSize.y = maximumFieldSize.y;
		contentSize.x = floor(fieldSize.width * contentSize.y / fieldSize.height);
		if (contentSize.x < kMinimumWindowWidth) contentSize.x = kMinimumWindowWidth;
		fieldSize = NS(q_2d_fit(Q(fieldSize), contentSize));
		_field.frame = NSMakeRect((contentSize.x - fieldSize.width) / 2.0, 0.0, fieldSize.width, fieldSize.height);
		[self.window.contentView setNeedsDisplay: YES];
		return NS(q_2d_add(contentSize, borderSize));
		}


#	pragma mark - IBAction


	- (IBAction) changeBall: (NSToolbarItem *) sender
		{_field.inputColor = sender.tag;}


	- (IBAction) closeDocument: (id) sender
		{[self.window performClose: self];}


	- (IBAction) saveDocument: (id) sender
		{
		if (_filepath)
			{
			NSError *error = [self saveAtPath: _filepath];

			if (error) [[NSAlert alertWithError: error] runModal];
			else if (_closeWindowAfterSave) [self.window performClose: self];
			}

		else [self saveDocumentAs: sender];
		}


	- (IBAction) saveDocumentAs: (id) sender
		{
		NSSavePanel *panel = [NSSavePanel savePanel];
		NSWindow *window = self.window;

		panel.allowedFileTypes = [NSArray arrayWithObject: @"bgl"];
		panel.canSelectHiddenExtension = YES;
		panel.nameFieldStringValue = _title;

		[panel beginSheetModalForWindow: self.window completionHandler: ^(NSInteger result)
			{
			BOOL closeWindow = _closeWindowAfterSave;

			_closeWindowAfterSave = NO;

			if (result == NSFileHandlingPanelOKButton)
				{
				NSError *error = [self saveAtPath: panel.URL.path];

				if (error) [[NSAlert alertWithError: error] runModal];

				else if (closeWindow)
					{
					[panel orderOut: self];
					[window performClose: self];
					}
				}
			}];
		}


	- (IBAction) clean: (id) sender
		{
		[_field clean];
		[self.window setDocumentEdited: YES];
		}


	- (IBAction) setSize: (id) sender
		{
		[NSApp	beginSheet:	sizeInputWindow
			modalForWindow: self.window
			modalDelegate:	self
			didEndSelector:	nil
			contextInfo:	nil];
		}


	- (IBAction) acceptSetSize: (id) sender
		{
		NSWindow *window = self.window;

		Q2DSize size = q_2d_value(SIZE)
			((qsize)[xSizeTextField.stringValue longLongValue],
			 (qsize)[ySizeTextField.stringValue longLongValue]);


		[NSApp endSheet: sizeInputWindow returnCode: 0];
		[sizeInputWindow orderOut: self];
		[_field prepareForSize: size];

		[window	animateIntoScreenFrame: window.screen.visibleFrame
			fromTopCenterToSize: [self
				windowWillResize: window
				toSize: NS(q_2d_add
					(Q([Field sizeToFitFieldOfSize: size bubbleDiameter: kDefaultBubbleRadius]),
					 q_2d_subtract(Q(window.frame.size), Q(((NSView *)window.contentView).frame.size))))]];
		}


	- (IBAction) cancelSetSize: (id) sender
		{
		[NSApp endSheet: sizeInputWindow returnCode: 0];
		[sizeInputWindow orderOut: self];
		}


	- (IBAction) fieldDidChange: (id) sender
		{
		[self.window setDocumentEdited: YES];
		}


@end

// EOF
