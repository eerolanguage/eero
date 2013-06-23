/*
     File: Texture.h
 Abstract:  A help class that loads an OpenGL texture from an image path.
*/ 

#import <Cocoa/Cocoa.h>

interface Texture

  initWithPath:(NSString*)path, return id
  textureName, return GLuint

end
