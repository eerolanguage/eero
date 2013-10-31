//
//  AXAProjectSettingsRetriever.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/27/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface AXAProjectSettingsRetriever : NSObject

  - (NSArray*) compilerOptionsForDocument: (id) document;

  - (void) clearCaches;

@end
