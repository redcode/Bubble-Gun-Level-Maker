/* BubbleGun Level Maker - DocumentController.h
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import "Field.h"

@interface DocumentController : NSWindowController <NSWindowDelegate> {
	IBOutlet NSWindow*    sizeInputWindow;
	IBOutlet NSTextField* xSizeTextField;
	IBOutlet NSTextField* ySizeTextField;

	NSString* _title;
	Field*	  _field;
	NSString* _filepath;
	NSWindow* _sizeInputWindow;
	BOOL	  _closeWindowAfterSave;
}
	@property (nonatomic, readonly) NSString* filePath;

	- (id) initWithFieldSize: (Q2DSize) size;

	- (id) initWithFile: (NSString *) filePath
	       error:	     (NSError **) error;

	- (IBAction) changeBall:     (id) sender;
	- (IBAction) closeDocument:  (id) sender;
	- (IBAction) saveDocument:   (id) sender;
	- (IBAction) saveDocumentAs: (id) sender;
	- (IBAction) clean:	     (id) sender;
	- (IBAction) setSize:	     (id) sender;
	- (IBAction) acceptSetSize:  (id) sender;
	- (IBAction) cancelSetSize:  (id) sender;
	- (IBAction) fieldDidChange: (id) sender;
@end

// EOF
