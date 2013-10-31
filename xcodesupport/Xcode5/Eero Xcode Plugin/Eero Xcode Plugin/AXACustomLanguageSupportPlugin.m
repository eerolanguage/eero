//
//  AXACustomLanguageSupportPlugin.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/27/13.
//  Copyright (c) 2013. All rights reserved.
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

