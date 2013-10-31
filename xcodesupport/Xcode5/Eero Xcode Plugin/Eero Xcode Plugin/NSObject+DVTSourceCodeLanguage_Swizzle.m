//
//  NSObject+DVTSourceCodeLanguage_Swizzle.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/19/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "AXASwizzling.h"
#import "AXACustomLanguageSupportPlugin.h"
#import "NSObject+DVTSourceCodeLanguage_Swizzle.h"

@protocol DVTSourceCodeLanguage_Swizzle_PrivateXcodeMethods
  // DVTSourceCodeLanguage
  + (id) sourceCodeLanguageForFileDataType: (id) type;
@end

//==================================================================================================
// This category is on NSObject because DVTSourceCodeLanguage is a private class within
// Xcode. This avoids having to link against Xcode private frameworks and creating
// stub classes.
//==================================================================================================
  @implementation NSObject (DVTSourceCodeLanguage_Swizzle)
//==================================================================================================

  //------------------------------------------------------------------------------------------------
  + (void) load {
  //------------------------------------------------------------------------------------------------
    AXAClassMethodSwizzle(NSClassFromString(@"DVTSourceCodeLanguage"),
                          @selector(sourceCodeLanguageForFileDataType:),
                          self,
                          @selector(DVTSwizzle_sourceCodeLanguageForFileDataType:));
  }

  //------------------------------------------------------------------------------------------------
  + (id)DVTSwizzle_sourceCodeLanguageForFileDataType:(id)fileDataType {
  //------------------------------------------------------------------------------------------------
    AXACustomLanguageSupport* customLanguage =
        [AXACustomLanguageSupportPlugin.sharedPlugin languageForFileDataType: fileDataType];

    if (customLanguage) {
      return customLanguage.sourceCodeLanguage;
    } else {
      return [self DVTSwizzle_sourceCodeLanguageForFileDataType: fileDataType];
    }
  }

@end
