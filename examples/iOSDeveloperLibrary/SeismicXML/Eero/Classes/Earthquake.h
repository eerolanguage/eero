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

  private
    // Magnitude of the earthquake on the Richter scale.
    CGFloat magnitude

    // Name of the location of the earthquake.
    String location

    // Date and time at which the earthquake occurred.
    Date date

    // Holds the URL to the USGS web page of the earthquake. The application uses this URL to open that page in Safari.
    URL USGSWebLink

    // Latitude and longitude of the earthquake. These properties are not displayed by the application, but are used to
    // create a URL for opening the Maps application. They could alternatively be used in conjuction with MapKit 
    // to be shown in a map view.
    //
    double latitude
    double longitude

  property (nonatomic, assign)
    CGFloat magnitude

  property (nonatomic, retain)
    String location
    Date date
    URL USGSWebLink

  property (nonatomic, assign)
    double latitude
    double longitude

end

