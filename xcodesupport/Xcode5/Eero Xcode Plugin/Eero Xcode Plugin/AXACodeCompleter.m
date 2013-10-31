//
//  AXACodeCompleter.m
//
//  Developed by: Andreas (Andy) Arvanitis
//                The Eero Programming Language
//                http://eerolanguage.org
//
//  Copyright (c) 2013, Andreas Arvanitis
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//      * Neither the name of the eerolanguage.org nor the
//        names of its contributors may be used to endorse or promote products
//        derived from this software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL ANDREAS ARVANITIS BE LIABLE FOR ANY
//  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "AXACodeCompleter.h"
#import "AXACodeCompleter_Protected.h"

@protocol AXACodeCompleter_PrivateXcodeMethods
  // DVTSourceCodeSymbolKind
  + (id)sourceCodeSymbolKinds;
  + (id)containerSymbolKind;
@end

//==================================================================================================
  @implementation AXACodeCompleter
//==================================================================================================
  {
  Class IndexCompletionItem;
  Class SourceCodeSymbolKind;
  }

  //------------------------------------------------------------------------------------------------
  - (id) init {
  //------------------------------------------------------------------------------------------------
    if (self = [super init]) {
      IndexCompletionItem = NSClassFromString(@"IDEIndexCompletionItem");
      SourceCodeSymbolKind = NSClassFromString(@"DVTSourceCodeSymbolKind");
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  // This is unfortunately a somewhat fragile and brute-force way to do this. However, other class
  // substitution attempts either didn't work at all or resulted in substandard functionality (e.g.
  // losing documentation feature).
  // Note that ARC must be disabled for (just) this source file.
  //------------------------------------------------------------------------------------------------
  - (id) createItemOfType: (NSString*) itemTypeText
              displayText: (NSString*) displayText
            insertionText: (NSString*) insertionText
               resultType: (NSString*) resultTypeText
                 priority: (NSUInteger) priority
                 disabled: (BOOL) disabled {
  //------------------------------------------------------------------------------------------------
    id item = [[[IndexCompletionItem alloc] init] autorelease];

    id symbolKind = nil;
    if (itemTypeText && itemTypeText.length) {
      for (id kind in [SourceCodeSymbolKind sourceCodeSymbolKinds]) {
        if ([[kind identifier] hasSuffix: itemTypeText]) {
          symbolKind = kind;
          break;
        }
      }
    }
    if (symbolKind == nil) { // it needs something(?)
      symbolKind = [SourceCodeSymbolKind containerSymbolKind];
    }

    object_setInstanceVariable(item, "_name", (void*)displayText);
    object_setInstanceVariable(item, "_symbolKind", (void*)symbolKind);
    object_setInstanceVariable(item, "_displayText", (void*)displayText);
    object_setInstanceVariable(item, "_displayType", (void*)resultTypeText);
    object_setInstanceVariable(item, "_completionText", (void*)insertionText);
    object_setInstanceVariable(item, "_priority", (void*)priority);
    object_setInstanceVariable(item, "_notRecommended", (void*)((long)disabled));

    return item;
  }

  //------------------------------------------------------------------------------------------------
  - (NSString*) placeholderFormatter {
  //------------------------------------------------------------------------------------------------
    return @"<#%s#>";
  }

@end


