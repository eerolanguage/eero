//
//  AXASourceCodeLanguage.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/21/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "AXASourceCodeLanguage.h"

@protocol AXASourceCodeLanguage_PrivateXcodeMethods
  // DVTSourceCodeLanguage
  + (id) sourceCodeLanguageWithIdentifier: (id) identifier;
@end


//==================================================================================================
  @implementation AXASourceCodeLanguage
//==================================================================================================
  {
  Class SourceCodeLanguage;
  }

  //------------------------------------------------------------------------------------------------
  - (id) init {
  //------------------------------------------------------------------------------------------------
    if (self = [super init]) {
      SourceCodeLanguage = NSClassFromString(@"DVTSourceCodeLanguage");
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (BOOL) isKindOfClass: (Class) aClass {
  //------------------------------------------------------------------------------------------------
    return (aClass == SourceCodeLanguage) ? YES : [super isKindOfClass: aClass];
  }

  //------------------------------------------------------------------------------------------------
  - (BOOL) conformsToLanguage: (id) language {
  //------------------------------------------------------------------------------------------------
    // Make this stand-in class part of the C family. This allows rich autocompletion.
    id C = [SourceCodeLanguage sourceCodeLanguageWithIdentifier: @"Xcode.SourceCodeLanguage.C"];
    return (language == C) ? YES : NO;
  }

  //------------------------------------------------------------------------------------------------
  - (BOOL) supportsIndentation {
  //------------------------------------------------------------------------------------------------
    return YES;
  }

@end
