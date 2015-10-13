/* BubbleGun Level Maker - Field.h
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Betty Lab. All rights reserved. */

#import <Cocoa/Cocoa.h>
#import <Z/types/base.h>

typedef struct {NSPoint point; zuint8 color;} Node;

@interface Field : NSView {
	Z2DSize	 _size;
	Node*	 _bubbles;
	NSSize	 _bubbleSize;
	NSColor* _colors[9];
	zuint8	 _inputColor;
	id	 _target;
	SEL	 _action;
}
	@property (nonatomic, readonly) Z2DSize	size;
	@property (nonatomic)		zuint8	inputColor;
	@property (nonatomic, assign)	id	target;
	@property (nonatomic)		SEL	action;

	+ (NSSize) sizeToFitFieldOfSize: (Z2DSize) size
		   bubbleDiameter:	 (CGFloat) bubbleDiameter;

	- (id) initWithFrame: (NSRect)	frame
	       size:	      (Z2DSize) size;

	- (id) initWithFrame: (NSRect) frame
	       data:	      (NSData *) data;

	- (void) prepareForSize: (Z2DSize) size;

	- (NSData *) data;

	- (void) clean;
@end

// EOF
