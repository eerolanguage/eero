/*
     File: ApplicationDelegate.m
 Abstract:  A simple application delegate. Initializes the application by registering the custom value transformers with NSValueTransformer and ensures that reasonable default data is presented to the user upon first launch.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */



#import <Cocoa/Cocoa.h>

#import "ApplicationDelegate.h"

#import "FahrenheitValueTransformer.h"
#import "CentigradeValueTransformer.h"
#import "RankineValueTransformer.h"

@implementation ApplicationDelegate
+ (void) initialize
{
    // Register our custom value transformers with NSValueTransformer.
    // These names are used in the "Transformer" field of the bindings
    // inspector within IB.    
    [NSValueTransformer setValueTransformer: [[CentigradeValueTransformer new] autorelease]
                                    forName: @"centrigradeFromKelvin"];
    [NSValueTransformer setValueTransformer: [[FahrenheitValueTransformer new] autorelease]
                                    forName: @"fahrenheitFromKelvin"];
    [NSValueTransformer setValueTransformer: [[RankineValueTransformer new] autorelease]
                                    forName: @"rankineFromKelvin"];
}

- (void) applicationWillFinishLaunching:(NSNotification *)aNotification
{
    // Register the Kelvin temperature for boiling water as the "first
    // run" value that will appear in the UI. 

    // Because the Kelvin temperature is stored as the value of the
    // "LastTemperature" key of the Shared Defaults controller,
    // whatever the user entered last will be automatically stored and
    // used upon the next launch of the application. 

    // Note that there is nothing particularly magical about value
    // transformers.  You are free to use them to transform values
    // within your code, as needed.   Since most people recognize
    // 100.00 as the boiling point of water more readily than the
    // kelvin value, the centigrade value transformer is used to
    // convert the centigrade boiling point of water to the kelvin
    // value. 
    NSValueTransformer *centrigradeFromKelvinTransformer = [NSValueTransformer valueTransformerForName:@"centrigradeFromKelvin"];
    NSNumber *kelvinWaterBoilingPoint = [centrigradeFromKelvinTransformer reverseTransformedValue: [NSNumber numberWithDouble:100.00]];
    NSDictionary *registrationDefaults = [NSDictionary dictionaryWithObject: kelvinWaterBoilingPoint
                                                                     forKey: @"LastTemperature"]; 
    [[NSUserDefaults standardUserDefaults] registerDefaults: registrationDefaults];
}

- (void) awakeFromNib
{
    // Programatically bind a value transformer to the rankine value
    // field.  The resulting binding is identical to the bindings
    // configured in Interface Builder for the Centigrade and
    // Fahrenheit fields.   We could also choose to bind a specific
    // instance of a value transformer by using the
    // "NSValueTransformer" option.  This could be used in a situation
    // where the value transformer needs more information than just
    // the value to perform the requested transformation.
    NSDictionary *bindingOptions = [NSDictionary dictionaryWithObject: @"rankineFromKelvin"
                                                               forKey: @"NSValueTransformerName"];
    [rankineTemperatureField bind: @"value"
                         toObject: sharedUserDefaultsController
                      withKeyPath: @"values.LastTemperature"
                          options: bindingOptions];
}
@end
