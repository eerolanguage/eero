//
//  NSObject+XCCompilerSpecificationClang_Swizzle.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/29/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AXAResolvedFilePath.h"
#import "AXASwizzling.h"

@interface NSObject (XCCompilerSpecification_Swizzle)
@end

@protocol XCCompilerSpecificationClang_Swizzle_PrivateXcodeMethods
  // PBXFileType
  - (BOOL)isSourceCode;

  // XCSpecification
  + (id) registeredSpecifications;
  + (id) specificationForIdentifier: (id) identifier;

  // PBXBuildRule
  + (id) systemBuildRules;
  - (id) compilerSpecificationIdentifier;

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
  static Class BuildRule = nil;
  static Class CompilerSpecification = nil;

  //------------------------------------------------------------------------------------------------
  + (void) load {
  //------------------------------------------------------------------------------------------------
    FileType = NSClassFromString(@"PBXFileType");
    BuildRule = NSClassFromString(@"PBXBuildRule");
    CompilerSpecification = NSClassFromString(@"XCCompilerSpecification");

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
                                             forLanguageDialect: (id) dialect {
  //--------------------------------------------------------------------------------------------------
    NSString* path = nil;

    if ([[(id)self name] hasPrefix: @"Static Analyzer"] &&
        [(id)self fileTypeForGccLanguageDialect: dialect] == nil) {

      static NSMutableDictionary* compilerInfoCache = nil;

      if (compilerInfoCache == nil) {
        compilerInfoCache = [NSMutableDictionary new];
      }
      if (!(path = compilerInfoCache[dialect])) {
        // TODO: there might be an easier way to do this
        for (id fileType in [FileType registeredSpecifications]) {
          if ([fileType isSourceCode]) {
            NSString* fileTypeDialect = [fileType stringForKey: @"GccDialectName"];
            if (fileTypeDialect && [fileTypeDialect isEqual: dialect]) {
              NSArray* systemBuildRules = [BuildRule systemBuildRules];
              for (id buildRule in systemBuildRules) {
                if ([[buildRule fileType] isEqual: fileType]) {
                  NSString* compilerSpecIdentifier = [buildRule compilerSpecificationIdentifier];
                  id compilerSpec =
                      [CompilerSpecification specificationForIdentifier: compilerSpecIdentifier];
                  path = [compilerSpec executablePath];
                  compilerInfoCache[dialect] = AXAResolvedFilePath(path);
                  break;
                }
              }
            }
          }
        }
      }
    }
    return path ? path : [self XCSwizzle_executablePathWithMacroExpansionScope: scope
                                                            forLanguageDialect: dialect];
  }

@end

