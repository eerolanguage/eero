//
//  AXACustomLanguageSupportPlugin.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/27/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AXACustomLanguageSupport.h"
#import "AXAProjectSettingsRetriever.h"

@interface AXACustomLanguageSupportPlugin : NSObject

  + (instancetype) sharedPlugin;

  - (AXACustomLanguageSupport*) languageForFileDataType: (id) fileDataType;
  - (AXACustomLanguageSupport*) languageForSourceCodeLanguage: (id) sourceCodeLanguage;

  @property (readonly) AXAProjectSettingsRetriever* projectSettings;

@end
