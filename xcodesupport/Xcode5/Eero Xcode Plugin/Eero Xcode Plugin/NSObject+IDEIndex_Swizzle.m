//
//  NSObject+IDEIndex_Swizzle.m
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
#import "NSObject+IDEIndex_Swizzle.h"

@protocol IDEIndex_Swizzle_PrivateXcodeMethods
  // IDEIndex
  - (id)symbolsMatchingName:(id)arg1 inContext:(id)arg2 withCurrentFileContentDictionary:(id)arg3;

  // DVTTextDocumentLocation
  - (id)initWithDocumentURL:(id)arg1 timestamp:(id)arg2 startingColumnNumber:(long long)arg3 endingColumnNumber:(long long)arg4 startingLineNumber:(long long)arg5 endingLineNumber:(long long)arg6 characterRange:(struct _NSRange)arg7;
  - (NSUInteger) startingLineNumber;
  - (NSUInteger) startingColumnNumber;

  // DVTDocumentLocation
  - (NSURL*) documentURL;

  // DVTSourceCodeSymbolKind
  + (id)globalVariableSymbolKind;

  // IDEIndexSymbol
  + (id)newSymbolOfKind:(id)arg1 language:(id)arg2 name:(id)arg3 resolution:(id)arg4 forQueryProvider:(id)arg5;
  - (void)setModelOccurrenceRole:(long long)arg1 location:(id)arg2;

  // DVTFileDataType
  + (id)fileDataTypeForFileURL:(id)arg1 error:(id *)arg2;

  // PBXFileReference
  - (id)initWithPath:(id)arg1;

//  + (BOOL)languageSupportsSymbolColoring:(id)arg1;

@end

//==================================================================================================
// This category is on NSObject because IDEIndex is a private class within
// Xcode. This avoids having to link against Xcode private frameworks and creating
// stub classes.
//==================================================================================================
  @implementation NSObject (IDEIndex_Swizzle)
//==================================================================================================

  static Class IndexSymbol = nil;
  static Class SourceCodeSymbolKind = nil;
  static Class TextDocumentLocation = nil;
  static Class FileDataType = nil;
  static Class FileReference = nil;


  //------------------------------------------------------------------------------------------------
  + (void)load {
  //------------------------------------------------------------------------------------------------
    IndexSymbol = NSClassFromString(@"IDEIndexSymbol");
    SourceCodeSymbolKind = NSClassFromString(@"DVTSourceCodeSymbolKind");
    TextDocumentLocation = NSClassFromString(@"DVTTextDocumentLocation");
    FileDataType = NSClassFromString(@"DVTFileDataType");
    FileReference = NSClassFromString(@"PBXFileReference");

    AXAMethodSwizzle(NSClassFromString(@"IDEIndex"),
                     @selector(symbolsMatchingName:inContext:withCurrentFileContentDictionary:),
                     NSObject.class,
                     @selector(DVTSwizzle_symbolsMatchingName:inContext:withCurrentFileContentDictionary:));

//    AXAClassMethodSwizzle(NSClassFromString(@"IDEIndex"),
//                     @selector(languageSupportsSymbolColoring:),
//                     NSObject.class,
//                     @selector(DVTSwizzle_languageSupportsSymbolColoring:));
  }

//
//  + (BOOL)DVTSwizzle_languageSupportsSymbolColoring:(id)arg1 {
//      BOOL value = [self DVTSwizzle_languageSupportsSymbolColoring:arg1];
////      NSLog(@"##### languageSupportsSymbolColoring %@ (%d)", arg1, value);
//      return YES;
//  }
//
//

  //------------------------------------------------------------------------------------------------
  - (id) DVTSwizzle_symbolsMatchingName: (NSString*) symbolName
                              inContext: (id) context
       withCurrentFileContentDictionary: (NSDictionary*) content {
  //------------------------------------------------------------------------------------------------
    NSArray* items = nil;

    if (symbolName) {
      NSURL* fileURL = [context documentURL];

      NSError* error = nil;
      id fileDataType = [FileDataType fileDataTypeForFileURL:fileURL error: &error];

      AXACustomLanguageSupportPlugin* sharedPlugin = [AXACustomLanguageSupportPlugin sharedPlugin];
      AXACustomLanguageSupport* customLanguage = [sharedPlugin languageForFileDataType: fileDataType];

      if (customLanguage) {
        id fileReference = [[FileReference alloc] initWithPath:[fileURL path]];

        NSArray* compilerOptions =
            [sharedPlugin.projectSettings compilerOptionsForFileReference: fileReference];

        NSDictionary* definition =
            [customLanguage.codeCompleter definitionOfSymbolAtLine: [context startingLineNumber]
                                                            column: [context startingColumnNumber]
                                                   compilerOptions: compilerOptions];
        if (definition) {
          NSURL* definitionFileURL = [NSURL fileURLWithPath: definition[@"path"]];
          NSUInteger line = [definition[@"line"] unsignedIntegerValue];
          NSUInteger column = [definition[@"column"] unsignedIntegerValue];

          id location = [[TextDocumentLocation alloc] initWithDocumentURL: definitionFileURL
                                                                timestamp: nil
                                                     startingColumnNumber: column
                                                       endingColumnNumber: column
                                                       startingLineNumber: line
                                                         endingLineNumber: line
                                                           characterRange: NSMakeRange(0,0)];

          id item = [IndexSymbol newSymbolOfKind: [SourceCodeSymbolKind globalVariableSymbolKind]
                                        language: @""
                                            name: symbolName
                                      resolution: nil
                                forQueryProvider: nil];
          [item setModelOccurrenceRole: 1 location: location];
          if (item) {
            return @[item];
          }
        }
      }
    }
    if (items == nil) {
      items = [self DVTSwizzle_symbolsMatchingName: symbolName
                                         inContext: context
                  withCurrentFileContentDictionary: content];
    }
    return items;
  }

@end
