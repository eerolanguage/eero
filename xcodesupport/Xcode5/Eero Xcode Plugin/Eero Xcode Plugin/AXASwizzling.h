//
//  AXASwizzling.h
//  Eero Xcode Plugin
//
//  Created by Andy Arvanitis on 10/19/13.
//  Copyright (c) 2013. All rights reserved.
//
#import <objc/runtime.h>

void AXAMethodSwizzle(Class primaryClass, SEL primarySel,
                      Class secondaryClass, SEL secondarySel);

void AXAClassMethodSwizzle(Class primaryClass, SEL primarySel,
                           Class secondaryClass, SEL secondarySel);

