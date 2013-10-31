//
//  AXAResolvedFilePath.m
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/30/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AXAResolvedFilePath.h"

//--------------------------------------------------------------------------------------------------
NSString* AXAResolvedFilePath(NSString* path) {

  NSArray* pathComponents = [path pathComponents];

  NSDictionary* environmentVariables = [NSProcessInfo.processInfo environment];

  NSMutableArray* resolvedPathComponents = [NSMutableArray new];

  for (NSString* component in pathComponents) {
    if ([component hasPrefix: @"$"]) {
      NSString* resolvedComponent =
          [component stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"$()"]];
      resolvedComponent = environmentVariables[resolvedComponent];
      if (resolvedComponent) {
        [resolvedPathComponents addObject: resolvedComponent];
      }
    } else {
      [resolvedPathComponents addObject: component];
    }
  }

  NSString* resolvedPath =
      [[NSString pathWithComponents: resolvedPathComponents] stringByStandardizingPath];

  return resolvedPath;
}

