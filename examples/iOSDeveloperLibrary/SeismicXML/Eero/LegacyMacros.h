//
//  LegacyMacros.h
//  SeismicXML
//
//  Created by Andy Arvanitis on 10/21/12.
//
//
#import <Foundation/Foundation.h>

// TODO: investigate direct use of legacy macros

static inline NSString* LocalizedString(NSString* key, NSString* comment) {
  return NSLocalizedString(key, comment);
}

static inline void Assert(int condition) {
  return assert(condition);
}
