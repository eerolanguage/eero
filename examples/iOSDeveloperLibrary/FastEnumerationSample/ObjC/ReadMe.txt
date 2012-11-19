FastEnumerationSample

FastEnumerationSample is a Mac OS X command line project that demonstrates how to implement the NSFastEnumeration protocol. In this sample the MyFastEnumerationSample class implements -countByEnumeratingWithState:objects:count: to return strings when used with the Obj-C 2.0 "for…in" construct. This sample avoids the issues of implementing a storage class in order to demonstrate the protocol. A real implementation would likely do less work to provide values, such as directly copying object pointers from an internal representation.

All code for this sample is in the FastEnumerationSample.mm source file. To view the sample's output in Xcode, open the Console by choosing "Console" from the "Run" menu (or entering Command-Shift-R). See the comments for -countByEnumeratingWithState:objects:count: for details on this sample's implementation. While provided as a Mac OS X application, the techniques demonstrated by this sample are fully applicable to iPhone OS development.

Keep in mind that while this sample demonstrates how to implement the NSFastEnumeration protocol, most developers will be better served by using one of the built in Foundation container classes, such as NSArray or NSDictionary, rather than implementing their own custom container class.

For more information on the NSFastEnumeration protocol, see the Fast Enumeration section of the Objective C 2.0 Programming Language guide at <http://developer.apple.com/DOCUMENTATION/Cocoa/Conceptual/ObjectiveC/Articles/ocFastEnumeration.html#//apple_ref/doc/uid/TP30001163-CH18-SW1>

Changes From Previous Versions

1.0: Initial Version

Copyright (C) 2009 Apple Inc. All rights reserved.