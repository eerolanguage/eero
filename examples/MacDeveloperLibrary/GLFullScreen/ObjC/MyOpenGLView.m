/*
     File: MyOpenGLView.m
 Abstract:  An NSView subclass that delegates to separate "scene" 
 and "controller" objects for OpenGL rendering and input event handling.
 
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

#import "MyOpenGLView.h"
#import "MainController.h"
#import "Scene.h"

@implementation MyOpenGLView

- (NSOpenGLContext*) openGLContext
{
	return openGLContext;
}

- (NSOpenGLPixelFormat*) pixelFormat
{
	return pixelFormat;
}

- (void) setMainController:(MainController*)theController;
{
	controller = theController;
}

- (CVReturn) getFrameForTime:(const CVTimeStamp*)outputTime
{
	// There is no autorelease pool when this method is called because it will be called from a background thread
	// It's important to create one or you will leak objects
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// Update the animation
	CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
	[[controller scene] advanceTimeBy:(currentTime - [controller renderTime])];
	[controller setRenderTime:currentTime];
	
	[self drawView];
	
	[pool release];
    return kCVReturnSuccess;
}

// This is the renderer output callback function
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp* now, const CVTimeStamp* outputTime, CVOptionFlags flagsIn, CVOptionFlags* flagsOut, void* displayLinkContext)
{
    CVReturn result = [(MyOpenGLView*)displayLinkContext getFrameForTime:outputTime];
    return result;
}

- (void) setupDisplayLink
{
	// Create a display link capable of being used with all active displays
	CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
	
	// Set the renderer output callback function
	CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, self);
	
	// Set the display link for the current renderer
	CGLContextObj cglContext = [[self openGLContext] CGLContextObj];
	CGLPixelFormatObj cglPixelFormat = [[self pixelFormat] CGLPixelFormatObj];
	CVDisplayLinkSetCurrentCGDisplayFromOpenGLContext(displayLink, cglContext, cglPixelFormat);
}

- (id) initWithFrame:(NSRect)frameRect shareContext:(NSOpenGLContext*)context
{
    NSOpenGLPixelFormatAttribute attribs[] =
    {
		kCGLPFAAccelerated,
		kCGLPFANoRecovery,
		kCGLPFADoubleBuffer,
		kCGLPFAColorSize, 24,
		kCGLPFADepthSize, 16,
		0
    };
	
    pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
	
    if (!pixelFormat)
		NSLog(@"No OpenGL pixel format");
	
	// NSOpenGLView does not handle context sharing, so we draw to a custom NSView instead
	openGLContext = [[NSOpenGLContext alloc] initWithFormat:pixelFormat shareContext:context];
	
	if (self = [super initWithFrame:frameRect]) {
		[[self openGLContext] makeCurrentContext];
		
		// Synchronize buffer swaps with vertical refresh rate
		GLint swapInt = 1;
		[[self openGLContext] setValues:&swapInt forParameter:NSOpenGLCPSwapInterval]; 
		
		[self setupDisplayLink];
		
		// Look for changes in view size
		// Note, -reshape will not be called automatically on size changes because NSView does not export it to override 
		[[NSNotificationCenter defaultCenter] addObserver:self 
												 selector:@selector(reshape) 
													 name:NSViewGlobalFrameDidChangeNotification
												   object:self];
	}
	
	return self;
}

- (id) initWithFrame:(NSRect)frameRect
{
	self = [self initWithFrame:frameRect shareContext:nil];
	return self;
}

- (void) lockFocus
{
	[super lockFocus];
	if ([[self openGLContext] view] != self)
		[[self openGLContext] setView:self];
}

- (void) reshape
{
	// This method will be called on the main thread when resizing, but we may be drawing on a secondary thread through the display link
	// Add a mutex around to avoid the threads accessing the context simultaneously
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	// Delegate to the scene object to update for a change in the view size
	[[controller scene] setViewportRect:[self bounds]];
	[[self openGLContext] update];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

- (void) drawRect:(NSRect)dirtyRect
{
	// Ignore if the display link is still running
	if (!CVDisplayLinkIsRunning(displayLink))
		[self drawView];
}

- (void) drawView
{
	// This method will be called on both the main thread (through -drawRect:) and a secondary thread (through the display link rendering loop)
	// Also, when resizing the view, -reshape is called on the main thread, but we may be drawing on a secondary thread
	// Add a mutex around to avoid the threads accessing the context simultaneously
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	// Make sure we draw to the right context
	[[self openGLContext] makeCurrentContext];
	
	// Delegate to the scene object for rendering
    [[controller scene] render];
	[[self openGLContext] flushBuffer];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}
 
- (BOOL) acceptsFirstResponder
{
    // We want this view to be able to receive key events
    return YES;
}

- (void) keyDown:(NSEvent *)theEvent
{
    // Delegate to the controller object for handling key events
    [controller keyDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    // Delegate to the controller object for handling mouse events
    [controller mouseDown:theEvent];
}

- (void) startAnimation
{
	if (displayLink && !CVDisplayLinkIsRunning(displayLink))
		CVDisplayLinkStart(displayLink);
}

- (void) stopAnimation
{
	if (displayLink && CVDisplayLinkIsRunning(displayLink))
		CVDisplayLinkStop(displayLink);
}

- (void) dealloc
{
	// Stop and release the display link
	CVDisplayLinkStop(displayLink);
    CVDisplayLinkRelease(displayLink);
	
	// Destroy the context
	[openGLContext release];
	[pixelFormat release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self 
													name:NSViewGlobalFrameDidChangeNotification
												  object:self];
	[super dealloc];
}	

@end
