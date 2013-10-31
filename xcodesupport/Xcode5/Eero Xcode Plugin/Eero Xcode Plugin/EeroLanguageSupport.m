//
//  EeroLanguageSupport.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/28/13.
//  Copyright (c) 2013. All rights reserved.
//
#import "AXALibclangCodeCompleter.h"
#import "EeroLanguageSupport.h"
#import "AXACustomLanguageSupport_Protected.h"

//==================================================================================================
  @implementation EeroLanguageSupport
//==================================================================================================
  {
  AXALibclangCodeCompleter* _codeCompleter;
  }

  //------------------------------------------------------------------------------------------------
  - (instancetype) initWithBundle: (NSBundle*) bundle {
  //------------------------------------------------------------------------------------------------
    if (self = [super initWithBundle: bundle]) {

      setenv("PLUGIN_PRIVATE_CLANG_LOCATION",
             strdup([[bundle.resourcePath stringByAppendingPathComponent:@".."] UTF8String]),
             YES);

      [self subscribeToNotifications];
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (void) dealloc {
  //------------------------------------------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] removeObserver:self];
  }

  //------------------------------------------------------------------------------------------------
  - (id) languageName {
  //------------------------------------------------------------------------------------------------
    return @"Eero";
  }

  //------------------------------------------------------------------------------------------------
  - (id) languageIdentifier {
  //------------------------------------------------------------------------------------------------
    return @"Xcode.SourceCodeLanguage.Eero";
  }

  //------------------------------------------------------------------------------------------------
  - (id) sourceFileIdentifier {
  //------------------------------------------------------------------------------------------------
    return @"org.eerolanguage.eero-source";
  }

  //------------------------------------------------------------------------------------------------
  - (id) languageSpecificationIdentifier {
  //------------------------------------------------------------------------------------------------
    return @"xcode.lang.eero";
  }

  //------------------------------------------------------------------------------------------------
  - (AXACodeCompleter*) codeCompleter {
  //------------------------------------------------------------------------------------------------
    return _codeCompleter;
  }

  //------------------------------------------------------------------------------------------------
  - (void) subscribeToNotifications {
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
  }

  //------------------------------------------------------------------------------------------------
  - (void) projectDidOpen: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    if (_codeCompleter == nil) {
      _codeCompleter = [AXALibclangCodeCompleter new];
    }
  }

  //------------------------------------------------------------------------------------------------
  - (void) projectDidClose: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    // TODO: Being very conservative here -- consider passing in project or breaking out methods
    [_codeCompleter clearCaches];
  }

  //------------------------------------------------------------------------------------------------
  - (void) projectDidChange: (NSNotification*) notification {
  //------------------------------------------------------------------------------------------------
    // TODO: Being very conservative here -- consider passing in project or breaking out methods
    [_codeCompleter clearCaches];
  }

@end

