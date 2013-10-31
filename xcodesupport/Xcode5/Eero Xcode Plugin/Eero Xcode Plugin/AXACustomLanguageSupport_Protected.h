//
//  AXACustomLanguageSpecification_Protected.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/28/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "AXACustomLanguageSupport.h"

@interface AXACustomLanguageSupport ()
  @property (readonly) NSString* languageName;
  @property (readonly) NSString* languageIdentifier;
  @property (readonly) NSString* sourceFileIdentifier;
  @property (readonly) NSString* languageSpecificationIdentifier;
@end
