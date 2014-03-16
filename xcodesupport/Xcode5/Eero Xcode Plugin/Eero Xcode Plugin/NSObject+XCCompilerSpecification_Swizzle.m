//
//  NSObject+XCCompilerSpecificationClang_Swizzle.m
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
#import "AXACustomLanguageSupportPlugin.h"
#import "AXASwizzling.h"

@interface NSObject (XCCompilerSpecification_Swizzle)
@end

@protocol XCCompilerSpecificationClang_Swizzle_PrivateXcodeMethods
  // PBXFileType
  - (BOOL)isSourceCode;

  // XCSpecification
  + (id) registeredSpecifications;
  + (id) specificationForIdentifier: (id) identifier;

  // XCCompilerSpecification
  - (id) executablePathWithMacroExpansionScope:(id) scope forLanguageDialect: (id) dialect;
  - (id) fileTypeForGccLanguageDialect: (id) dialect;
@end


//==================================================================================================
// This category is on NSObject because XCCompilerSpecificationClang is a private class within
// Xcode. This avoids having to link against Xcode private frameworks and creating
// stub classes.
//==================================================================================================
  @implementation NSObject (XCCompilerSpecificationClang_Swizzle)
//==================================================================================================

  static Class FileType = nil;

  //------------------------------------------------------------------------------------------------
  + (void) load {
  //------------------------------------------------------------------------------------------------
    FileType = NSClassFromString(@"PBXFileType");
    Class CompilerSpecificationClang = NSClassFromString(@"XCCompilerSpecificationClang");

    AXAMethodSwizzle(CompilerSpecificationClang,
                     @selector(executablePathWithMacroExpansionScope:forLanguageDialect:),
                     self,
                     @selector(XCSwizzle_executablePathWithMacroExpansionScope:forLanguageDialect:));
  }

  //--------------------------------------------------------------------------------------------------
  // For the built-in static analyzer, if the language dialect is not supported (i.e. it's a
  // custom language), try to use the language's normal compiler instead.
  //--------------------------------------------------------------------------------------------------
  - (NSString*) XCSwizzle_executablePathWithMacroExpansionScope: (id) scope
                                             forLanguageDialect: (NSString*) dialect {
  //--------------------------------------------------------------------------------------------------
    NSString* path = nil;

    if ([(id)self fileTypeForGccLanguageDialect: dialect] == nil) {
      static NSMutableDictionary* compilerInfoCache = nil;

      if (compilerInfoCache == nil) {
        compilerInfoCache = [NSMutableDictionary new];
      }
      if (!(path = compilerInfoCache[dialect])) {
        // TODO: there might be an easier way to do this
        for (id fileType in [FileType registeredSpecifications]) {
          if ([fileType isSourceCode]) {
            NSString* fileTypeDialect = [fileType stringForKey: @"GccDialectName"];
            if (fileTypeDialect && [fileTypeDialect isEqualToString: dialect]) {
              NSString* UTI = [fileType stringForKey: @"UTI"];
              AXACustomLanguageSupport* customLanguage =
                  [AXACustomLanguageSupportPlugin.sharedPlugin languageForFileTypeUTI: UTI];
              compilerInfoCache[dialect] = customLanguage.executablePath;
              break;
            }
          }
        }
      }
    }
    return path ? path : [self XCSwizzle_executablePathWithMacroExpansionScope: scope
                                                            forLanguageDialect: dialect];
  }

@end

