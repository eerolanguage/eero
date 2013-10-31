//
//  AXACodeCompleter.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/21/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <Foundation/Foundation.h>

@protocol AXACodeCompleter

  @required

  - (id) createItemOfType: (NSString*) itemTypeIdentifier
              displayText: (NSString*) displayText
            insertionText: (NSString*) insertionText
               resultType: (NSString*) resultTypeText
                 priority: (NSUInteger) priority
                 disabled: (BOOL) disabled;

  @optional

  // Note: Convention for this method is lines and columns start at 0
  //
  - (BOOL) addCodeCompleteItemsToArray: (NSMutableArray*) items
                   usingSourceCodeText: (NSString*) text
                                  line: (NSUInteger) line
                                column: (NSUInteger) column
                       compilerOptions: (NSArray*) options;

  - (void)clearCaches;

@end


@interface AXACodeCompleter : NSObject <AXACodeCompleter>
@end

