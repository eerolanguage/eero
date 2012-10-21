
// Eero conversion of example source code provided by Apple.
//
// This file based on file:
//     TemperatureConverter/ObjC/RankineValueTransformer.h
//
// Please see it for Apple license details.
//
// Abstract: Converts Kelvin units to Rankine units.  Supports reverse transformations.
//

interface RankineValueTransformer : ValueTransformer

  //--------------------------------------------------------------------------------------
  + transformedValueClass, return Class

  //--------------------------------------------------------------------------------------
  + allowsReverseTransformation, return BOOL

  //--------------------------------------------------------------------------------------
  transformedValue: id, return id

  //--------------------------------------------------------------------------------------
  reverseTransformedValue: id, return id

end
