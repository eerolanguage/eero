//
//  AXACustomLanguageSupport.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/28/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AXACodeCompleter.h"

@interface AXACustomLanguageSupport : NSObject

  - (instancetype) initWithBundle: (NSBundle*) bundle;

  @property (readonly) id fileDataType;
  @property (readonly) id sourceCodeLanguage;
  @property (readonly) AXACodeCompleter* codeCompleter;

@end


