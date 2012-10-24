/*
     File: main.m
 Abstract: This example shows how to do Objective C message forwarding in Foundation.
  Version: 1.0
 
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
 
 Copyright (C) 2009 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#include <stdio.h>


@interface TargetProxy : NSProxy {
    id realObject1;
    id realObject2;
}

- (id)initWithTarget1:(id)t1 target2:(id)t2;

@end

int main(int argc, const char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    // Create an empty mutable string, which will be one of the
    // real objects for the proxy.
    NSMutableString *string = [[NSMutableString alloc] init];

    // Create an empty mutable array, which will be the other
    // real object for the proxy.
    NSMutableArray *array = [[NSMutableArray alloc] init];

    // Create a proxy to wrap the real objects.  This is rather
    // artificial for the purposes of this example -- you'd rarely
    // have a single proxy covering two objects.  But it is possible.
    id proxy = [[TargetProxy alloc] initWithTarget1:string target2:array];

    // Note that we can't use appendFormat:, because vararg methods
    // cannot be forwarded!
    [proxy appendString:@"This "];
    [proxy appendString:@"is "];
    [proxy addObject:string];
    [proxy appendString:@"a "];
    [proxy appendString:@"test!"];

    NSLog(@"count should be 1, it is: %d", [proxy count]);
    
    if ([[proxy objectAtIndex:0] isEqualToString:@"This is a test!"]) {
        NSLog(@"Appending successful.", proxy);
    } else {
        NSLog(@"Appending failed, got: '%@'", proxy);
    }

    NSLog(@"Example finished without errors.");
    [pool release];
    return 0;
}


@implementation TargetProxy

- (id)initWithTarget1:(id)t1 target2:(id)t2 {
    realObject1 = [t1 retain];
    realObject2 = [t2 retain];
    return self;
}

- (void)dealloc {
    [realObject1 release];
    [realObject2 release];
    [super dealloc];
}

// The compiler knows the types at the call site but unfortunately doesn't
// leave them around for us to use, so we must poke around and find the types
// so that the invocation can be initialized from the stack frame.

// Here, we ask the two real objects, realObject1 first, for their method
// signatures, since we'll be forwarding the message to one or the other
// of them in -forwardInvocation:.  If realObject1 returns a non-nil
// method signature, we use that, so in effect it has priority.
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSMethodSignature *sig;
    sig = [realObject1 methodSignatureForSelector:aSelector];
    if (sig) return sig;
    sig = [realObject2 methodSignatureForSelector:aSelector];
    return sig;
}

// Invoke the invocation on whichever real object had a signature for it.
- (void)forwardInvocation:(NSInvocation *)invocation {
    id target = [realObject1 methodSignatureForSelector:[invocation selector]] ? realObject1 : realObject2;
    [invocation invokeWithTarget:target];
}

// Override some of NSProxy's implementations to forward them...
- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([realObject1 respondsToSelector:aSelector]) return YES;
    if ([realObject2 respondsToSelector:aSelector]) return YES;
    return NO;
}

@end
