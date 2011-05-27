//
//  Copyright (c) 2011 Andreas Arvanitis.  All rights reserved.
//
//  Developed by: Andreas (Andy) Arvanitis
//                The Eero Programming Language
//                http://eerolanguage.org
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal with the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//    1. Redistributions of source code must retain the above copyright notice,
//       this list of conditions and the following disclaimers.
//
//    2. Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimers in the
//       documentation and/or other materials provided with the distribution.
//
//    3. Neither the names of Andreas Arvanitis, The Eero Programming Language,
//       nor the names of its contributors may be used to endorse
//       or promote products derived from this Software without specific prior
//       written permission.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  CONTRIBUTORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  WITH THE SOFTWARE.

#import "StringOperators.h"

// Category for Eero string operators. Written in Objective-C to minimize
// changes to this library as changes are mode to Eero itself.
//
@implementation NSString (eero_operators)

// Simple concatenation operator. Returns a new string.
//
- (NSString*) plus: (NSString*)aString {
    return [self stringByAppendingString:aString];
  }

// Returns new string which has argument string removed from original.
//
- (NSString*) minus: (NSString*)aString {
    return [self stringByReplacingOccurrencesOfString:aString withString:@""];
  }

// Case-sensitive comparison -- returns YES (true) if receiver precedes the argument
// string (assumes ascending order). Uses NSString's "compare" method.
// Not that operator ">=" is also implicitly defined by this.
//
- (BOOL) isLess: (NSString*)aString {
    return ([self compare:aString] == NSOrderedAscending);
  }

// Case-sensitive comparison -- returns YES (true) if receiver follows the argument
// the argument string. Uses NSString's "compare" method.
// Not that operator "<=" is also implicitly defined by this.
//
- (BOOL) isGreater: (NSString*)aString {
    return ([self compare:aString] == NSOrderedDescending);
  }

// Overloads array accessor operator "[]". Returns single-character string at 
// position specified.
//
- (id) objectAtIndex: (NSUInteger)index {
    NSRange range = NSMakeRange( index, 1 );
    return [self substringWithRange:range];
  }


@end


