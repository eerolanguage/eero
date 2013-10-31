//
//  AXASwizzling.c
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/19/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <objc/runtime.h>
#import "AXASwizzling.h"

//--------------------------------------------------------------------------------------------------
void AXAMethodSwizzle(Class primaryClass, SEL primarySel,
                      Class secondaryClass, SEL secondarySel) {

  Method primaryMethod = class_getInstanceMethod(primaryClass, primarySel);
  Method secondaryMethod = class_getInstanceMethod(secondaryClass, secondarySel);

  if ((primaryMethod != nil) && (secondaryMethod != nil)) {
    method_exchangeImplementations(primaryMethod, secondaryMethod);
  }
}

//--------------------------------------------------------------------------------------------------
void AXAClassMethodSwizzle(Class primaryClass, SEL primarySel,
                           Class secondaryClass, SEL secondarySel) {

  Method primaryMethod = class_getClassMethod(primaryClass, primarySel);
  Method secondaryMethod = class_getClassMethod(secondaryClass, secondarySel);

  if ((primaryMethod != nil) && (secondaryMethod != nil)) {
    method_exchangeImplementations(primaryMethod, secondaryMethod);
  }
}

