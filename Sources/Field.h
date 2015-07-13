/* BubbleGun Level Maker - Field.h
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>
#import <Q/types/base.h>

typedef struct {NSPoint point; quint8 color;} Node;

@interface Field : NSView {
	Q2DSize	 _size;
	Node*	 _bubbles;
	NSSize	 _bubbleSize;
	NSColor* _colors[9];
	quint8	 _inputColor;
	id	 _target;
	SEL	 _action;
}
	@property (nonatomic, readonly) Q2DSize	size;
	@property (nonatomic)		quint8	inputColor;
	@property (nonatomic, assign)	id	target;
	@property (nonatomic)		SEL	action;

	+ (NSSize) sizeToFitFieldOfSize: (Q2DSize) size
		   bubbleDiameter:	 (CGFloat) bubbleDiameter;

	- (id) initWithFrame: (NSRect)	frame
	       size:	      (Q2DSize) size;

	- (id) initWithFrame: (NSRect) frame
	       data:	      (NSData *) data;

	- (void) prepareForSize: (Q2DSize) size;

	- (NSData *) data;

	- (void) clean;
@end

// EOF
