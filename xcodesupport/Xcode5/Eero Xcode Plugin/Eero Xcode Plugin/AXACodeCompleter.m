//
//  AXACodeCompleter.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/27/13.
//  Copyright (c) 2013. All rights reserved.
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


