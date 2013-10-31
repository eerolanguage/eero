//
//  AXASourceCodeLanguage.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/21/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AXASourceCodeLanguage : NSObject

  - (BOOL)conformsToLanguage: (id)language;
  - (BOOL)supportsIndentation;

  @property (retain) Class      nativeSourceModelParserClass;
  @property (retain) NSString*  documentationAbbreviation;
  @property (retain) NSString*  languageName;
  @property (retain) NSString*  identifier;
  @property (retain) NSArray*   conformedToLanguages;
  @property (retain) NSArray*   fileDataTypes;
  @property (retain) id         languageSpecification;

@end
