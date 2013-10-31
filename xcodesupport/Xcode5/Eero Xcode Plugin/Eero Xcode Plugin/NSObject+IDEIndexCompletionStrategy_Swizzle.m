//
//  NSObject+IDEIndexCompletionStrategy_Swizzle.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/21/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "AXASwizzling.h"
#import "AXACustomLanguageSupportPlugin.h"
#import "NSObject+IDEIndexCompletionStrategy_Swizzle.h"

@protocol IDEIndexCompletionStrategy_Swizzle_PrivateXcodeMethods
  // DVTTextDocumentLocation
  - (NSUInteger) startingLineNumber;
  - (NSUInteger) startingColumnNumber;

  // IDEIndexCompletionStrategy
  - (NSMutableArray*) completionItemsForDocumentLocation: (id) location
                                                 context: (NSDictionary*) context
                                           areDefinitive: (BOOL*) definitive;
@end

//==================================================================================================
// This category is on NSObject because IDEIndexCompletionStrategy is a private class within
// Xcode. This avoids having to link against Xcode private frameworks and creating
// stub classes.
//==================================================================================================
  @implementation NSObject (IDEIndexCompletionStrategy_Swizzle)
//==================================================================================================

  //------------------------------------------------------------------------------------------------
  + (void)load {
  //------------------------------------------------------------------------------------------------
    AXAMethodSwizzle(NSClassFromString(@"IDEIndexCompletionStrategy"),
                     @selector(completionItemsForDocumentLocation:context:areDefinitive:),
                     NSObject.class,
                     @selector(DVTSwizzle_completionItemsForDocumentLocation:context:areDefinitive:));
  }

  //------------------------------------------------------------------------------------------------
  - (NSMutableArray*) DVTSwizzle_completionItemsForDocumentLocation: (id) location
                                                            context: (NSDictionary*) context
                                                      areDefinitive: (BOOL*) definitive {
  //------------------------------------------------------------------------------------------------
    NSMutableArray* items;

    id language = context[@"DVTTextCompletionContextSourceCodeLanguage"];

    AXACustomLanguageSupportPlugin* sharedPlugin = [AXACustomLanguageSupportPlugin sharedPlugin];
    AXACustomLanguageSupport* customLanguage = [sharedPlugin languageForSourceCodeLanguage: language];

    if (customLanguage) {
      items = [NSMutableArray array];

      id document = context[@"IDETextCompletionContextDocumentKey"];
      id text     = context[@"DVTTextCompletionContextTextStorageString"];

      NSArray* compilerOptions = [sharedPlugin.projectSettings compilerOptionsForDocument: document];

      [customLanguage.codeCompleter addCodeCompleteItemsToArray: items
                                            usingSourceCodeText: text
                                                           line: [location startingLineNumber]
                                                         column: [location startingColumnNumber]
                                                compilerOptions: compilerOptions];
      *definitive = YES;

    } else {
      items = [self DVTSwizzle_completionItemsForDocumentLocation: location
                                                          context: context
                                                    areDefinitive: definitive];
    }
    return items;
  }

@end
