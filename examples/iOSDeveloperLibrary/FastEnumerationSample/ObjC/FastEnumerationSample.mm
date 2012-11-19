/*
    File: FastEnumerationSample.mm
Abstract: Demonstrates how to implement the NSFastEnumeration protocol
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
#import <vector>

@interface MyFastEnumerationSample : NSObject<NSFastEnumeration>
{
	std::vector<NSInteger> list;
}

-(id)initWithCapacity:(NSUInteger)numItems;

@end

@implementation MyFastEnumerationSample

// Designated initializer for this class.
// Since this is just a sample, we'll generate some random data
// for the enumeration to return later.
-(id)initWithCapacity:(NSUInteger)numItems
{
	self = [super init];
	if(self != nil)
	{
		for(NSInteger i = 0; i < numItems; ++i)
		{
			list.push_back(random());
		}
	}
	return self;
}

// This is where all the magic happens.
// You have two choices when implementing this method:
// 1) Use the stack based array provided by stackbuf. If you do this, then you must respect the value of 'len'.
// 2) Return your own array of objects. If you do this, return the full length of the array returned until you run out of objects, then return 0. For example, a linked-array implementation may return each array in order until you iterate through all arrays.
// In either case, state->itemsPtr MUST be a valid array (non-nil). This sample takes approach #1, using stackbuf to store results.
-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
	NSUInteger count = 0;
	// This is the initialization condition, so we'll do one-time setup here.
	// Ensure that you never set state->state back to 0, or use another method to detect initialization
	// (such as using one of the values of state->extra).
	if(state->state == 0)
	{
		// We are not tracking mutations, so we'll set state->mutationsPtr to point into one of our extra values,
		// since these values are not otherwise used by the protocol.
		// If your class was mutable, you may choose to use an internal variable that is updated when the class is mutated.
		// state->mutationsPtr MUST NOT be NULL.
		state->mutationsPtr = &state->extra[0];
	}
	// Now we provide items, which we track with state->state, and determine if we have finished iterating.
	if(state->state < list.size())
	{
		// Set state->itemsPtr to the provided buffer.
		// Alternate implementations may set state->itemsPtr to an internal C array of objects.
		// state->itemsPtr MUST NOT be NULL.
		state->itemsPtr = stackbuf;
		// Fill in the stack array, either until we've provided all items from the list
		// or until we've provided as many items as the stack based buffer will hold.
		while((state->state < list.size()) && (count < len))
		{
			// For this sample, we generate the contents on the fly.
			// A real implementation would likely just be copying objects from internal storage.
			stackbuf[count] = [NSString stringWithFormat:@"Item %i = %i", state->state, list[state->state]];
			state->state++;
			count++;
		}
	}
	else
	{
		// We've already provided all our items, so we signal we are done by returning 0.
		count = 0;
	}
	return count;
}

@end

int main (int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	// And to demonstrate, we create an instance of our enumeration sample class and enumerate over its contents.
	srandomdev();
	MyFastEnumerationSample *example = [[MyFastEnumerationSample alloc] initWithCapacity:50];
	for(id item in example)
	{
		NSLog(@"%@", item);
	}

    [pool drain];
    return 0;
}
