/* BubbleGun Level Maker - MainController.h
__________     ___    ___      __	    ________
\    __   \__ _\_ |___\_ |___ |  |   ____  /  _____/ __ __  ____
 |   | ) _/  |	\     \|     \|  | _/ __ \/   \  ___|  |  \/    \
 |   |_)  \  |	/  |)  \  |)  \  |_\   __/\    \_\  \  |  /   |  \
 |________/____/|______/______/____/\_____/\________/____/|___|__/
Copyright © 2014-2015 Manuel Sainz de Baranda y Goñi.
Released under the terms of the GNU General Public License v3. */

#import <Cocoa/Cocoa.h>

@interface MainController : NSObject <NSApplicationDelegate> {
	NSMutableArray *_documentControllers;
}
@end

// EOF