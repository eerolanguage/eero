//
//  NSObject+IDEIndexCompletionStrategy_Swizzle.m
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
