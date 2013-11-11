//
//  EeroLanguageSupport.m
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
#import "AXALibclangCodeCompleter.h"
#import "EeroLanguageSupport.h"
#import "AXACustomLanguageSupport_Protected.h"

//==================================================================================================
  @implementation EeroLanguageSupport
//==================================================================================================
  {
  AXALibclangCodeCompleter* _codeCompleter;
  NSString* _executablePath;
  }

  //------------------------------------------------------------------------------------------------
  - (instancetype) initWithBundle: (NSBundle*) bundle {
  //------------------------------------------------------------------------------------------------
    if (self = [super initWithBundle: bundle]) {

      NSMutableArray* pathComponents = [NSMutableArray arrayWithObject: bundle.resourcePath];

      [pathComponents addObject: @".."];
      [pathComponents addObject: @"usr"];
      [pathComponents addObject: @"bin"];
      [pathComponents addObject: @"clang"];

      _executablePath = [[NSString pathWithComponents: pathComponents] stringByStandardizingPath];

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
  - (NSString*) executablePath {
  //------------------------------------------------------------------------------------------------
    return _executablePath;
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

