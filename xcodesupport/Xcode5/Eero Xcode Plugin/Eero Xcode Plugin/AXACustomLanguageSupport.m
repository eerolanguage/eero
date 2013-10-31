//
//  AXACustomLanguageSupport.m
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
#import "AXASourceCodeLanguage.h"
#import "AXACustomLanguageSupport.h"
#import "AXACustomLanguageSupport_Protected.h"

@protocol AXACustomLanguageSpecification_PrivateXcodeMethods
  // DVTSourceSpecification
  + (id) specificationRegistry;
  - (id) initWithPropertyListDictionary: (NSDictionary*) dict;

  // DVTFileDataType
  + (id) fileDataTypeWithIdentifier: (NSString*) identifier;
@end

//==================================================================================================
  @implementation AXACustomLanguageSupport
//==================================================================================================
  {
  NSBundle* _bundle;
  id _fileDataType;
  id _sourceCodeLanguage;
  }

  //------------------------------------------------------------------------------------------------
  - (instancetype) initWithBundle: (NSBundle*) bundle {
  //------------------------------------------------------------------------------------------------
    if (self = [super init]) {
      _bundle = bundle;
      [self registerLanguage];
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (void) registerLanguage {
  //------------------------------------------------------------------------------------------------
    // Get and save source file type
    Class FileDataType = NSClassFromString(@"DVTFileDataType");
    _fileDataType = [FileDataType fileDataTypeWithIdentifier: self.sourceFileIdentifier];

    if (self.fileDataType) {
      NSDictionary* registry = [self loadAndRegisterSpecificationFile];

      AXASourceCodeLanguage * sourceCodeLanguage = [AXASourceCodeLanguage new];

      sourceCodeLanguage.languageName = self.languageName;
      sourceCodeLanguage.identifier = self.languageIdentifier;
      sourceCodeLanguage.languageSpecification = registry[self.languageSpecificationIdentifier];
      sourceCodeLanguage.fileDataTypes = @[ self.fileDataType ];

      _sourceCodeLanguage = sourceCodeLanguage;
    }
  }

  //------------------------------------------------------------------------------------------------
  - (NSDictionary*) loadAndRegisterSpecificationFile {
  //------------------------------------------------------------------------------------------------
    Class LanguageSpecification = NSClassFromString(@"DVTLanguageSpecification");

    NSMutableDictionary* specificationRegistry = [LanguageSpecification specificationRegistry];

    NSString* specFile = [_bundle pathForResource: self.languageName ofType: @"xclangspec"];
    if (specFile) {
      NSData* specFileData = [NSData dataWithContentsOfFile: specFile];
      if (specFileData) {
        NSError* error = nil;
        NSArray* specPropertyList =
            [NSPropertyListSerialization propertyListWithData: specFileData
                                                      options: NSPropertyListImmutable
                                                       format: NULL
                                                        error: &error];
        if (!error && specPropertyList) {
          for (NSDictionary* item in specPropertyList) {
            NSString* key = item[@"Identifier"];
            id spec = [[LanguageSpecification alloc] initWithPropertyListDictionary:item];
            if (spec) {
              specificationRegistry[key] = spec;
            }
          }
        }
      }
    }
    return specificationRegistry;
  }

@end
