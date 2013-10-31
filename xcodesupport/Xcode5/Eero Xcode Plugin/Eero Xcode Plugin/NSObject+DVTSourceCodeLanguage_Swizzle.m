//
//  NSObject+DVTSourceCodeLanguage_Swizzle.m
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
#import "AXASwizzling.h"
#import "AXACustomLanguageSupportPlugin.h"
#import "NSObject+DVTSourceCodeLanguage_Swizzle.h"

@protocol DVTSourceCodeLanguage_Swizzle_PrivateXcodeMethods
  // DVTSourceCodeLanguage
  + (id) sourceCodeLanguageForFileDataType: (id) type;
@end

//==================================================================================================
// This category is on NSObject because DVTSourceCodeLanguage is a private class within
// Xcode. This avoids having to link against Xcode private frameworks and creating
// stub classes.
//==================================================================================================
  @implementation NSObject (DVTSourceCodeLanguage_Swizzle)
//==================================================================================================

  //------------------------------------------------------------------------------------------------
  + (void) load {
  //------------------------------------------------------------------------------------------------
    AXAClassMethodSwizzle(NSClassFromString(@"DVTSourceCodeLanguage"),
                          @selector(sourceCodeLanguageForFileDataType:),
                          self,
                          @selector(DVTSwizzle_sourceCodeLanguageForFileDataType:));
  }

  //------------------------------------------------------------------------------------------------
  + (id)DVTSwizzle_sourceCodeLanguageForFileDataType:(id)fileDataType {
  //------------------------------------------------------------------------------------------------
    AXACustomLanguageSupport* customLanguage =
        [AXACustomLanguageSupportPlugin.sharedPlugin languageForFileDataType: fileDataType];

    if (customLanguage) {
      return customLanguage.sourceCodeLanguage;
    } else {
      return [self DVTSwizzle_sourceCodeLanguageForFileDataType: fileDataType];
    }
  }

@end
