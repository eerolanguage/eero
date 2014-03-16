//
//  AXAProjectSettingsRetriever.m
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
#import "AXAProjectSettingsRetriever.h"

@protocol AXAProjectSettingsRetriever_PrivateXcodeMethods
  // PBXContainer
  - (id) buildConfigurationList;

  // PBXProject
  + (id) openProjects;
  - (id) targetsForFileReference: (id) fileReference justNative: (BOOL) native;

  // PBXReference
  - (NSString*) resolvedAbsolutePath;

  // Xcode3FileReference
  - (id) reference;

  // XCConfigurationList
  - (id) buildConfigurations;

  // XCBuildConfiguration
  - (id) buildSettings;
  - (NSString*) inspectorDisplayName;

  // DVTMacroDefinitionTable
  - (NSDictionary*) dictionaryRepresentation;

  // DVTSDK
  + (id) sdkForCanonicalName: (NSString*) name;
  - (id) sdkPath;

  // DVTFilePath
  - (NSString*) pathString;

  // IDESourceCodeDocument
  - (NSArray*) knownFileReferences;
@end

//==================================================================================================
  @implementation AXAProjectSettingsRetriever
//==================================================================================================
  {
  Class Project;
  NSMutableDictionary* _compilerOptionsForFilePath;
  }

  //------------------------------------------------------------------------------------------------
  - (id) init {
  //------------------------------------------------------------------------------------------------
    if ((self = [super init])) {
      Project = NSClassFromString(@"PBXProject");
      _compilerOptionsForFilePath = [NSMutableDictionary new];
    }
    return self;
  }

  //------------------------------------------------------------------------------------------------
  - (void) dealloc {
  //------------------------------------------------------------------------------------------------
    [self clearCaches];
  }

  //------------------------------------------------------------------------------------------------
  - (void)clearCaches {
  //------------------------------------------------------------------------------------------------
    [_compilerOptionsForFilePath removeAllObjects];
  }


  //------------------------------------------------------------------------------------------------
  - (NSArray*) compilerOptionsForDocument: (id) document {
  //------------------------------------------------------------------------------------------------
   id fileReference = [[document knownFileReferences][0] reference];
   return [self compilerOptionsForFileReference: fileReference];
  }

  //------------------------------------------------------------------------------------------------
  - (NSArray*) compilerOptionsForFileReference: (id) fileReference {
  //------------------------------------------------------------------------------------------------
    NSString* filePath = [fileReference resolvedAbsolutePath];
    NSArray* options = [_compilerOptionsForFilePath objectForKey: filePath];

    if (options == nil) {
      NSArray* openProjects = [Project openProjects];
      id project = nil;
      id target = nil;

      for (id openProject in openProjects) {
        NSArray* targets = [openProject targetsForFileReference: fileReference justNative: YES];
        if (targets.count > 0) {
          target = targets[0]; // TODO: how do we get the active target?
          project = openProject;
          break;
        }
      }

      if (target) {
        NSDictionary* projectSettings = [self activeBuildSettingsForContainer: project];
        NSDictionary* targetSettings  = [self activeBuildSettingsForContainer: target];
        if (projectSettings && targetSettings) {
          options = [self relevantCompilerOptionsForFile: filePath
                                           settingsArray: @[projectSettings, targetSettings]];
        }
      }

      if (options) {
        [_compilerOptionsForFilePath setObject: options forKey: filePath];
      }
    }

    return options;
  }

  //------------------------------------------------------------------------------------------------
  - (NSDictionary*) activeBuildSettingsForContainer: (id) container {
  //------------------------------------------------------------------------------------------------
    NSDictionary* settings = nil;
    id buildConfigurationList = [container buildConfigurationList];
    if (buildConfigurationList) {
      id activeConfiguration = nil;
      NSArray* configurations = [buildConfigurationList buildConfigurations];
      for (NSUInteger i = 0; i < configurations.count; i++) {
        id configuration = configurations[i];
        NSString* name = [configuration inspectorDisplayName];
        if ([name rangeOfString:@"(Active)"].location != NSNotFound) {
          activeConfiguration = configuration;
          break;
        }
      }
      if (activeConfiguration) {
        settings = [[activeConfiguration buildSettings] dictionaryRepresentation];
      }
    }

    return settings;
  }

  //------------------------------------------------------------------------------------------------
  #define SET_VALUE_IF_FOUND(value, setting) {\
      id newValue = setting;\
      if (newValue) value = newValue;\
      }

  //------------------------------------------------------------------------------------------------
  #define SET_ARRAY_VALUE_IF_FOUND(value, setting) {\
      id newValue = setting;\
      if (newValue && [newValue count]) value = newValue;\
      }

  //------------------------------------------------------------------------------------------------
  - (NSArray*) relevantCompilerOptionsForFile: (NSString*) filename
                                settingsArray: (NSArray*) settingsArray {
  //------------------------------------------------------------------------------------------------

    // First option (compiler arg) is the file name
    NSMutableArray* options = [NSMutableArray arrayWithObject: filename];

    NSString* sysRoot = nil;
    NSArray* headerSearchPaths = nil;
    NSArray* userHeaderSearchPaths = nil;
    NSArray* frameworkSearchPaths = nil;
    NSString* modules = nil;
    NSString* arc = nil;
    NSString* objcExceptions = nil;

    // We only want the last value. In other words, later settings values in the input array
    // take priority over previous values.
    //
    for (NSDictionary* settings in settingsArray) {
      SET_VALUE_IF_FOUND(sysRoot, settings[@"SDKROOT"]);
      SET_ARRAY_VALUE_IF_FOUND(headerSearchPaths, settings[@"HEADER_SEARCH_PATHS"]);
      SET_ARRAY_VALUE_IF_FOUND(userHeaderSearchPaths, settings[@"USER_HEADER_SEARCH_PATHS"]);
      SET_ARRAY_VALUE_IF_FOUND(frameworkSearchPaths, settings[@"FRAMEWORK_SEARCH_PATHS"]);
      SET_VALUE_IF_FOUND(modules, settings[@"CLANG_ENABLE_MODULES"]);
      SET_VALUE_IF_FOUND(arc, settings[@"CLANG_ENABLE_OBJC_ARC"]);
      SET_VALUE_IF_FOUND(objcExceptions, settings[@"GCC_ENABLE_OBJC_EXCEPTIONS"]);
    }

    if (sysRoot) {
      sysRoot = [self sdkRootPathForName: sysRoot];
      [options addObject: [NSString stringWithFormat: @"-isysroot%@", sysRoot]];
    }

    if (headerSearchPaths) {
      for (NSString* path in headerSearchPaths) {
        [options addObject: [NSString stringWithFormat: @"-I%@", path]];
      }
    }

    if (userHeaderSearchPaths) {
      for (NSString* path in userHeaderSearchPaths) {
        [options addObject: [NSString stringWithFormat: @"-I%@", path]];
      }
    }

    if (frameworkSearchPaths) {
      for (NSString* path in frameworkSearchPaths) {
        [options addObject: [NSString stringWithFormat: @"-F%@", path]];
      }
    }

    if ([modules isEqualToString: @"YES"]) {
      [options addObject: @"-fmodules"];
    }

    if ([arc isEqualToString: @"YES"]) {
      [options addObject: @"-fobjc-arc"];
    }

    if ([objcExceptions isEqualToString: @"YES"]) {
      [options addObject: @"-fobjc-exceptions"];
    }

    return options;
  }

  //------------------------------------------------------------------------------------------------
  - (NSString*) sdkRootPathForName: (NSString*) name {
  //------------------------------------------------------------------------------------------------
    Class SDK = NSClassFromString(@"DVTSDK");
    return [[[SDK sdkForCanonicalName: name] sdkPath] pathString];
  }

@end
