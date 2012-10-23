//
// Eero conversion of example source code provided by Apple.
//
// This file based on file:
//     SeismicXML/ObjC/ParseOperation.h
//
// Please see it for Apple license details.
//
// Abstract: The NSOperation class used to perform the XML parsing of earthquake data.
//
#import <Foundation/Foundation.h>

extern const String kAddEarthquakesNotif
extern const String kAddEarthquakesNotif
extern const String kEarthquakeResultsKey
extern const String kEarthquakesErrorNotif
extern const String kEarthquakesMsgErrorKey

// Forward declaration
//
class Earthquake

interface ParseOperation : Operation

  protected
    Data earthquakeData

  private
    DateFormatter dateFormatter
    
  private // these variables are used during parsing
    Earthquake* currentEarthquakeObject
    MutableArray currentParseBatch;
    MutableString currentParsedCharacterData
    
    BOOL accumulatingParsedCharacterData
    BOOL didAbortParsing
    UInteger parsedEarthquakesCounter


  property (copy, readonly)
    Data earthquakeData

  initWithData: Data, return id

end


