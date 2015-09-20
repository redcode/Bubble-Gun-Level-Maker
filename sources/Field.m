/* BubbleGun Level Maker - Field.m
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import "Field.h"
#import <Z/functions/base/Z2DValue.h>
#define Y_INCREMENT 0.866025403784439

typedef Z_STRICT_STRUCTURE (
	zuint8 width;
	zuint8 height;
	zuint8 bubbles[];
) BGL;


@implementation Field


#	pragma mark - Helpers


	- (void) updateGeometry
		{
		zsize x, y = 0;
		NSPoint point;
		Node *node = _bubbles;

		_bubbleSize	    = self.bounds.size;
		_bubbleSize.width  /= (CGFloat)_size.x;
		_bubbleSize.height /= (_size.y - 1) * Y_INCREMENT + 1.0;

		for (	y = 0, point.y = 0.0;
			y < _size.y;
			y++, point.y += _bubbleSize.height * Y_INCREMENT
		)
			{
			if (y & 1) for (
				x = 0, point.x = _bubbleSize.width / 2.0;
				x < _size.x - 1;
				x++, point.x += _bubbleSize.width, node++
			)
				node->point = point;

			else for (
				x = 0, point.x = 0.0;
				x < _size.x;
				x++, point.x += _bubbleSize.width, node++
			)
				node->point = point;
			}
		}


	- (void) resetColors
		{
		Node *e = _bubbles, *n = e + _size.x * _size.y - _size.y / 2;

		while (n != e) (--n)->color = 0;
		}


	- (Node *) nodeForEvent: (NSEvent *) event
		{
		NSPoint eventPoint = [self convertPoint: event.locationInWindow fromView: nil];
		NSPoint delta;
		CGFloat radius = MIN(_bubbleSize.width, _bubbleSize.height) / 2.0;
		Node *n = _bubbles, *e = n + _size.x * _size.y - _size.y / 2;

		for (; n != e; n++)
			{
			delta = NSMakePoint
				(n->point.x + radius - eventPoint.x,
				 n->point.y + radius - eventPoint.y);

			if (hypot(delta.x, delta.y) <= radius) return n;
			}

		return NULL;
		}


#	pragma mark - Property Accessors


	@synthesize inputColor = _inputColor;
	@synthesize target     = _target;
	@synthesize action     = _action;

	- (Z2DSize) size {return _size;}


#	pragma mark - Overwritten


	- (id) initWithFrame: (NSRect) frame
		{
		if ((self = [super initWithFrame: frame]))
			{
			_colors[0] = [[NSColor colorWithCalibratedWhite: 0.85 alpha: 1.0] retain];
			_colors[1] = [[NSColor blackColor ] retain];
			_colors[2] = [[NSColor redColor	  ] retain];
			_colors[3] = [[NSColor orangeColor] retain];
			_colors[4] = [[NSColor yellowColor] retain];
			_colors[5] = [[NSColor greenColor ] retain];
			_colors[6] = [[NSColor blueColor  ] retain];
			_colors[7] = [[NSColor purpleColor] retain];
			_colors[8] = [[NSColor whiteColor ] retain];
			}

		return self;
		}


	- (id) initWithFrame: (NSRect ) frame
	       size:	      (Z2DSize) size
		{
		if ((self = [self initWithFrame: frame]))
			{
			[self prepareForSize: size];
			[self updateGeometry];
			[self resetColors];
    			}
    
		return self;
		}


	- (id) initWithFrame: (NSRect  ) frame
	       data:	      (NSData *) data
		{
		NSUInteger index, dataSize = [data length];
		BGL *BGL = (void *)[data bytes];

		if (dataSize < 2 || BGL->width * BGL->height - BGL->height / 2 != dataSize - 2)
			goto error;

		for (index = dataSize - 2; index;) if (BGL->bubbles[--index] > 8) goto error;

		if ((self = [self initWithFrame: frame]))
			{
			[self prepareForSize: z_2d_type(SIZE)((zsize)BGL->width, (zsize)BGL->height)];
			[self updateGeometry];
			for (index = dataSize - 2; index--;) _bubbles[index].color = BGL->bubbles[index];
			}

		return self;
		error: [self release]; return nil;
		}


	- (void) dealloc
		{
		free(_bubbles);
		for (NSUInteger index = 9; index;) [_colors[--index] release];
		[super dealloc];
		}


	- (BOOL) isFlipped
		{return YES;}


	- (void) setFrame: (NSRect) frame
		{
		[super setFrame: frame];
		[self updateGeometry];
		self.needsDisplay = YES;
		}


	- (void) mouseDown: (NSEvent *) event
		{
		Node *node = [self nodeForEvent: event];

		if (node != NULL)
			{
			zuint8 color = _inputColor + 1;

			node->color = node->color ? (node->color == color ? 0 : color) : color;
			self.needsDisplay = YES;
			if (_target) [_target performSelector: _action withObject: self];
			}
		}


	- (void) rightMouseDown: (NSEvent *) event
		{
		Node *node = [self nodeForEvent: event];

		if (node != NULL)
			{
			node->color = 0;
			self.needsDisplay = YES;
			if (_target) [_target performSelector: _action withObject: self];
			}
		}


	- (void) drawRect: (NSRect) frame
		{
		Node *n = _bubbles, *e = n + _size.x * _size.y - _size.y / 2;
		NSBezierPath *path = [[NSBezierPath alloc] init];
		[[NSColor colorWithCalibratedWhite: 0.0 alpha: 0.2] setStroke];

		for (; n != e; n++)
			{
			[_colors[n->color] setFill];

			[path appendBezierPathWithOvalInRect: NSMakeRect
				(n->point.x, n->point.y, _bubbleSize.width, _bubbleSize.height)];

			[path fill];
			[path removeAllPoints];

			if (n->color)
				{
				[path appendBezierPathWithOvalInRect: NSMakeRect
					(n->point.x + 0.5, n->point.y + 0.5,
					 _bubbleSize.width - 1.0, _bubbleSize.height - 1.0)];

				[path stroke];
				[path removeAllPoints];
				}
			}

		[path release];
		}


#	pragma mark - Public


	+ (NSSize) sizeToFitFieldOfSize: (Z2DSize) size
		   bubbleDiameter:	 (CGFloat) bubbleDiameter
		{
		return NSMakeSize
			(bubbleDiameter * (CGFloat)size.x,
			 ((CGFloat)size.y - 1) * bubbleDiameter * Y_INCREMENT + bubbleDiameter);
		}


	- (void) prepareForSize: (Z2DSize) size
		{
		_size	 = size;
		_bubbles = realloc(_bubbles, (size.x * size.y - size.y / 2) * sizeof(Node));
		[self updateGeometry];
		[self resetColors];
		}


	- (NSData *) data
		{
		zsize bubbleCount = _size.x * _size.y - _size.y / 2, index = 0;
		NSMutableData *data = [NSMutableData dataWithLength: 2 + bubbleCount];
		BGL *BGL = (void *)[data bytes];

		BGL->width = _size.x;
		BGL->height = _size.y;
		for (; index != bubbleCount; index++) BGL->bubbles[index] = _bubbles[index].color;
		return data;
		}


	- (void) clean
		{
		Node *e = _bubbles, *n = e + _size.x * _size.y - _size.y / 2;

		while (n != e) (--n)->color = 0;
		self.needsDisplay = YES;
		}


@end

// EOF
