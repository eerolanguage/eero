/*
     File: MainControler.m
 Abstract:  A controller object that handles full-screen/window modes 
 switching and user interactions.
 
  Version: 1.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
*/

#import "MainController.h"
#import "MyOpenGLView.h"
#import "Scene.h"

@implementation MainController

- (IBAction) goFullScreen:(id)sender
{
	isInFullScreenMode = YES;
	
	// Pause the non-fullscreen view
	[openGLView stopAnimation];
	
	// Mac OS X 10.6 and later offer a simplified mechanism to create full-screen contexts
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	
	NSRect mainDisplayRect, viewRect;
	
	// Create a screen-sized window on the display you want to take over
	// Note, mainDisplayRect has a non-zero origin if the key window is on a secondary display
	mainDisplayRect = [[NSScreen mainScreen] frame];
	fullScreenWindow = [[NSWindow alloc] initWithContentRect:mainDisplayRect styleMask:NSBorderlessWindowMask 
													 backing:NSBackingStoreBuffered defer:YES];
	
	// Set the window level to be above the menu bar
	[fullScreenWindow setLevel:NSMainMenuWindowLevel+1];
	
	// Perform any other window configuration you desire
	[fullScreenWindow setOpaque:YES];
	[fullScreenWindow setHidesOnDeactivate:YES];
	
	// Create a view with a double-buffered OpenGL context and attach it to the window
	// By specifying the non-fullscreen context as the shareContext, we automatically inherit the OpenGL objects (textures, etc) it has defined
	viewRect = NSMakeRect(0.0, 0.0, mainDisplayRect.size.width, mainDisplayRect.size.height);
	fullScreenView = [[MyOpenGLView alloc] initWithFrame:viewRect shareContext:[openGLView openGLContext]];
	[fullScreenWindow setContentView:fullScreenView];
	
	// Show the window
	[fullScreenWindow makeKeyAndOrderFront:self];
	
	// Set the scene with the full-screen viewport and viewing transformation
	[scene setViewportRect:viewRect];
	
	// Assign the view's MainController to self
	[fullScreenView setMainController:self];
	
	if (!isAnimating) {
		// Mark the view as needing drawing to initalize its contents
		[fullScreenView setNeedsDisplay:YES];
	}
	else {
		// Start playing the animation
		[fullScreenView startAnimation];
	}
	
#else
	// Mac OS X 10.5 and eariler require additional work to capture the display and set up a special context
	// This demo uses CGL for full-screen rendering on pre-10.6 systems. You may also use NSOpenGL to achieve this.
	
	CGLPixelFormatObj pixelFormatObj;
	GLint numPixelFormats;
	
	// Capture the main display
	CGDisplayCapture(kCGDirectMainDisplay);
	
	// Set up an array of attributes
	CGLPixelFormatAttribute attribs[] = {
		
		// The full-screen attribute
		kCGLPFAFullScreen,
		
		// The display mask associated with the captured display
		// We may be on a multi-display system (and each screen may be driven by a different renderer), so we need to specify which screen we want to take over. For this demo, we'll specify the main screen.
		kCGLPFADisplayMask, CGDisplayIDToOpenGLDisplayMask(kCGDirectMainDisplay),
		
		// Attributes common to full-screen and non-fullscreen
		kCGLPFAAccelerated,
		kCGLPFANoRecovery,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
        0
    };
	
	// Create the full-screen context with the attributes listed above
	// By specifying the non-fullscreen context as the shareContext, we automatically inherit the OpenGL objects (textures, etc) it has defined
	CGLChoosePixelFormat(attribs, &pixelFormatObj, &numPixelFormats);
	CGLCreateContext(pixelFormatObj, [[openGLView openGLContext] CGLContextObj], &fullScreenContextObj);
	CGLDestroyPixelFormat(pixelFormatObj);
	
	if (!fullScreenContextObj) {
        NSLog(@"Failed to create full-screen context");
		CGReleaseAllDisplays();
		[self goWindow];
        return;
    }
	
	// Set the current context to the one to use for full-screen drawing
	CGLSetCurrentContext(fullScreenContextObj);
	
	// Attach a full-screen drawable object to the current context
	CGLSetFullScreen(fullScreenContextObj);
	
    // Lock us to the display's refresh rate
    GLint newSwapInterval = 1;
    CGLSetParameter(fullScreenContextObj, kCGLCPSwapInterval, &newSwapInterval);
	
	// Tell the scene the dimensions of the area it's going to render to, so it can set up an appropriate viewport and viewing transformation
    [scene setViewportRect:NSMakeRect(0, 0, CGDisplayPixelsWide(kCGDirectMainDisplay), CGDisplayPixelsHigh(kCGDirectMainDisplay))];
	
	// Perform the application's main loop until exiting full-screen
	// The shift here is from a model in which we passively receive events handed to us by the AppKit (in window mode)
	// to one in which we are actively driving event processing (in full-screen mode)
	while (isInFullScreenMode)
	{
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		// Check for and process input events
        NSEvent *event;
        while (event = [NSApp nextEventMatchingMask:NSAnyEventMask untilDate:[NSDate distantPast] inMode:NSDefaultRunLoopMode dequeue:YES])
		{
            switch ([event type])
			{
                case NSLeftMouseDown:
                    [self mouseDown:event];
                    break;
					
                case NSLeftMouseUp:
                    [self mouseUp:event];
                    break;
					
                case NSLeftMouseDragged:
                    [self mouseDragged:event];
                    break;
					
                case NSKeyDown:
                    [self keyDown:event];
                    break;
					
                default:
                    break;
            }
        }
		
		// Update our animation
        CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
        if (isAnimating) {
            [scene advanceTimeBy:(currentTime - renderTime)];
        }
        renderTime = currentTime;
		
		// Delegate to the scene object for rendering
		[scene render];
		CGLFlushDrawable(fullScreenContextObj);
		
		[pool release];
	}
	
#endif
}

- (void) goWindow
{
	isInFullScreenMode = NO;
	
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
	
	// Release the screen-sized window and view
	[fullScreenWindow release];
	[fullScreenView release];
	
#else
	
	// Set the current context to NULL
	CGLSetCurrentContext(NULL);
	// Clear the drawable object
	CGLClearDrawable(fullScreenContextObj);
	// Destroy the rendering context
	CGLDestroyContext(fullScreenContextObj);
	// Release the displays
	CGReleaseAllDisplays();
	
#endif
	
	// Switch to the non-fullscreen context
	[[openGLView openGLContext] makeCurrentContext];
	
	if (!isAnimating) {
		// Mark the view as needing drawing
		// The animation has advanced while we were in full-screen mode, so its current contents are stale
		[openGLView setNeedsDisplay:YES];
	}
	else {
		// Continue playing the animation
		[openGLView startAnimation];
	}
}

- (void) awakeFromNib
{
	// Allocate the scene object
	scene = [[Scene alloc] init];
	
	// Assign the view's MainController to self
	[openGLView setMainController:self];
	
	// Activate the display link now
	[openGLView startAnimation];
	isAnimating = YES;
}

- (void) dealloc
{
	[scene release];
	[super dealloc];
}

- (Scene*) scene
{
	return scene;
}

- (CFAbsoluteTime) renderTime
{
	return renderTime;
}

- (void) setRenderTime:(CFAbsoluteTime)time
{
	renderTime = time;
}

- (void) startAnimation
{
	if (!isAnimating)
	{
		if (!isInFullScreenMode)
			[openGLView startAnimation];
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
		else
			[fullScreenView startAnimation];
#endif
		isAnimating = YES;
	}
}

- (void) stopAnimation
{
	if (isAnimating)
	{
		if (!isInFullScreenMode)
			[openGLView stopAnimation];
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
		else
			[fullScreenView stopAnimation];
#endif
		isAnimating = NO;
	}
}

- (void) toggleAnimation
{
	if (isAnimating)
		[self stopAnimation];
	else
		[self startAnimation];
}

- (void) keyDown:(NSEvent *)event
{
    unichar c = [[event charactersIgnoringModifiers] characterAtIndex:0];
    switch (c) {
			
		// [Esc] exits full-screen mode
        case 27:
			if (isInFullScreenMode)
				[self goWindow];
            break;
			
		// [space] toggles rotation of the globe
        case 32:
            [self toggleAnimation];
            break;
			
		// [W] toggles wireframe rendering
        case 'w':
        case 'W':
            [scene toggleWireframe];
            break;
			
        default:
            break;
    }
}

// Holding the mouse button and dragging the mouse changes the "roll" angle (y-axis) and the direction from which sunlight is coming (x-axis).
- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL dragging = YES;
    NSPoint windowPoint;
    NSPoint lastWindowPoint = [theEvent locationInWindow];
    float dx, dy;
	BOOL wasAnimating = isAnimating;
	
    if (wasAnimating) {
        [self stopAnimation];
    }
	
    while (dragging)
	{
        theEvent = [[openGLView window] nextEventMatchingMask:NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        windowPoint = [theEvent locationInWindow];
        switch ([theEvent type])
		{
            case NSLeftMouseUp:
                dragging = NO;
                break;
				
            case NSLeftMouseDragged:
                dx = windowPoint.x - lastWindowPoint.x;
                dy = windowPoint.y - lastWindowPoint.y;
                [scene setSunAngle:[scene sunAngle] - 1.0 * dx];
                [scene setRollAngle:[scene rollAngle] - 0.5 * dy];
                lastWindowPoint = windowPoint;
				
				if (isInFullScreenMode) {
#if MAC_OS_X_VERSION_MIN_REQUIRED > MAC_OS_X_VERSION_10_5
					[fullScreenView display];
#else
                    [scene render];
                    CGLFlushDrawable(fullScreenContextObj);
#endif
                }
				else {
					[openGLView display];
				}
                break;
				
            default:
                break;
        }
    }
	
    if (wasAnimating) {
        [self startAnimation];
        renderTime = CFAbsoluteTimeGetCurrent();
    }
}

@end
