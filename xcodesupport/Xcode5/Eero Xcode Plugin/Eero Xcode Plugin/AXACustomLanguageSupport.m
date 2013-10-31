//
//  AXACustomLanguageSupport.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/28/13.
//  Copyright (c) 2013. All rights reserved.
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
