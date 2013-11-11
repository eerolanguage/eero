//
//  AXACustomLanguageSupportPlugin.m
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
#import <AppKit/AppKit.h>
#import "EeroLanguageSupport.h"
#import "AXACustomLanguageSupportPlugin.h"

//==================================================================================================
  @implementation AXACustomLanguageSupportPlugin
//==================================================================================================
  {
  NSBundle* _pluginBundle;
  NSMutableSet* _customLanguages;
  AXAProjectSettingsRetriever* _projectSettings;
  }

  // Private class variables
  //
  static AXACustomLanguageSupportPlugin* sharedPlugin = nil;

  //------------------------------------------------------------------------------------------------
  + (void) pluginDidLoad: (NSBundle*) plugin {
  //------------------------------------------------------------------------------------------------
    sharedPlugin = [[self alloc] initWithBundle: plugin];
  }

  //------------------------------------------------------------------------------------------------
  + (instancetype) sharedPlugin {
  //------------------------------------------------------------------------------------------------
    return sharedPlugin;
  }

  //------------------------------------------------------------------------------------------------
  - (id) initWithBundle: (NSBundle*) bundle {
  //------------------------------------------------------------------------------------------------
    if (self = [super init]) {

      _pluginBundle = bundle;

      [NSNotificationCenter.defaultCenter addObserver: self
                                              selector: @selector( applicationDidFinishLaunching: )
                                                  name: NSApplicationDidFinishLaunchingNotification
                                                object: nil];
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (void) dealloc {
  //------------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  }

  //------------------------------------------------------------------------------------------------
  - (AXACustomLanguageSupport*) languageForFileDataType: (id) fileDataType {
  //------------------------------------------------------------------------------------------------
    for (AXACustomLanguageSupport* language in _customLanguages) {
      if (fileDataType == language.fileDataType) {
        return language;
      }
    }
    return nil;
  }

  //------------------------------------------------------------------------------------------------
  - (AXACustomLanguageSupport*) languageForFileTypeUTI: (NSString*) UTI {
  //------------------------------------------------------------------------------------------------
    for (AXACustomLanguageSupport* language in _customLanguages) {
      if ([UTI isEqual: [language.fileDataType identifier]]) {
        return language;
      }
    }
    return nil;
  }

  //------------------------------------------------------------------------------------------------
  - (AXACustomLanguageSupport*) languageForSourceCodeLanguage: (id) sourceCodeLanguage {
  //------------------------------------------------------------------------------------------------
    for (AXACustomLanguageSupport* language in _customLanguages) {
      if (sourceCodeLanguage == language.sourceCodeLanguage) {
        return language;
      }
    }
    return nil;
  }

  //------------------------------------------------------------------------------------------------
  - (void) addCustomLanguages {
  //------------------------------------------------------------------------------------------------
    _customLanguages = [NSMutableSet new];

    [_customLanguages addObject: [[EeroLanguageSupport alloc] initWithBundle: _pluginBundle]];
  }

  //------------------------------------------------------------------------------------------------
  - (void) applicationDidFinishLaunching: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter addObserver: self
                           selector: @selector( projectDidOpen: )
                               name: @"PBXProjectDidOpenNotification"
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector( projectDidClose: )
                               name: @"PBXProjectDidCloseNotification"
                             object: nil];

    [notificationCenter addObserver: self
                           selector: @selector( projectDidChange: )
                               name: @"PBXProjectDidChangeNotification"
                             object: nil];

    [self addCustomLanguages];
  }

  //------------------------------------------------------------------------------------------------
  - (void) projectDidOpen: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    if (_projectSettings == nil) {
      _projectSettings = [AXAProjectSettingsRetriever new];
    }
  }

  //------------------------------------------------------------------------------------------------
  - (void) projectDidClose: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    // TODO: Being very conservative here -- consider passing in project or breaking out methods
    [self.projectSettings clearCaches];
  }

  //------------------------------------------------------------------------------------------------
  - (void) projectDidChange: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    // TODO: Being very conservative here -- consider passing in project or breaking out methods
    [self.projectSettings clearCaches];
  }

@end

