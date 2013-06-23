//
// Eero conversion of example source code provided by Apple.
//
// This file based on file:
//     SeismicXML/ObjC/Earthquake.h
//
// Please see it for Apple license details.
//
// Abstract: The model class that stores the information about an earthquake.
//
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

interface Earthquake

  CGFloat magnitude {nonatomic, assign}

  String location   {nonatomic, retain}
  Date date         {nonatomic, retain}
  URL USGSWebLink   {nonatomic, retain}

  double latitude, longitude  {nonatomic, assign}

end

