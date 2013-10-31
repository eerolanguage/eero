//
//  AXATranslationUnitWrapper.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/27/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "clang-c/Index.h"
#import "AXATranslationUnitWrapper.h"

//==================================================================================================
  @implementation AXATranslationUnitWrapper
//==================================================================================================
  {
  CXTranslationUnit _translationUnit;
  }

  //------------------------------------------------------------------------------------------------
  - (instancetype) initWithTranslationUnit: (CXTranslationUnit) translationUnit {
  //------------------------------------------------------------------------------------------------
    if (self = [super init]) {
      _translationUnit = translationUnit;
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (CXTranslationUnit) translationUnit {
  //------------------------------------------------------------------------------------------------
    return _translationUnit;
  }

  //------------------------------------------------------------------------------------------------
  - (void) dealloc {
  //------------------------------------------------------------------------------------------------
    clang_disposeTranslationUnit(_translationUnit);
  }

@end
