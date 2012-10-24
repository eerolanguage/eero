/*
     File: Texture.m
 Abstract:  A help class that loads an OpenGL texture from an image path.
 
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

#import "Texture.h"
#import <OpenGL/glu.h>

#define TEXTURE_WIDTH		1024
#define TEXTURE_HEIGHT		512

@interface Texture (PrivateMethods)

- (BOOL) getImageDataFromPath:(NSString*)path;
- (void) loadTexture;

@end

@implementation Texture

- (id) initWithPath:(NSString*)path
{	
	if (self = [super init]) {
		if ([self getImageDataFromPath:path])
			[self loadTexture];
	}
	return self;
}

- (GLuint) textureName
{
	return texId;
}

- (BOOL) getImageDataFromPath:(NSString*)path
{
	NSUInteger				width, height;
	NSURL					*url = nil;
	CGImageSourceRef		src;
	CGImageRef				image;
	CGContextRef			context = nil;
	CGColorSpaceRef			colorSpace;
	
	data = (GLubyte*) calloc(TEXTURE_WIDTH * TEXTURE_HEIGHT * 4, sizeof(GLubyte));
	
	url = [NSURL fileURLWithPath: path];
	src = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
	
	if (!src) {
		NSLog(@"No image");
		free(data);
		return NO;
	}
	
	image = CGImageSourceCreateImageAtIndex(src, 0, NULL);
	CFRelease(src);
	
	width = CGImageGetWidth(image);
	height = CGImageGetHeight(image);
	
	colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host);
	CGColorSpaceRelease(colorSpace);
	
	// Core Graphics referential is upside-down compared to OpenGL referential
	// Flip the Core Graphics context here
	// An alternative is to use flipped OpenGL texture coordinates when drawing textures
	CGContextTranslateCTM(context, 0.0, height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	// Set the blend mode to copy before drawing since the previous contents of memory aren't used. This avoids unnecessary blending.
	CGContextSetBlendMode(context, kCGBlendModeCopy);
	
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
	
	CGContextRelease(context);
	CGImageRelease(image);
	
	return YES;
}

- (void) loadTexture
{
	glGenTextures(1, &texId);
	glGenBuffers(1, &pboId);
	
	// Bind the texture
	glBindTexture(GL_TEXTURE_2D, texId);
	
	// Bind the PBO
	glBindBuffer(GL_PIXEL_UNPACK_BUFFER, pboId);
	
	// Upload the texture data to the PBO
	glBufferData(GL_PIXEL_UNPACK_BUFFER, TEXTURE_WIDTH * TEXTURE_HEIGHT * 4 * sizeof(GLubyte), data, GL_STATIC_DRAW);
	
	// Setup texture parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glPixelStorei(GL_UNPACK_ROW_LENGTH, 0);
	
	// OpenGL likes the GL_BGRA + GL_UNSIGNED_INT_8_8_8_8_REV combination
	// Use offset instead of pointer to indictate that we want to use data copied from a PBO		
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, TEXTURE_WIDTH, TEXTURE_HEIGHT, 0, 
				 GL_BGRA, GL_UNSIGNED_INT_8_8_8_8_REV, 0);
	
	// We can delete the application copy of the texture data now
	free(data);
	
	glBindTexture(GL_TEXTURE_2D, 0);
	glBindBuffer(GL_PIXEL_UNPACK_BUFFER, 0);
}

- (void) dealloc
{
	glDeleteTextures(1, &texId);
	glDeleteBuffers(1, &pboId);
	[super dealloc];
}

@end
