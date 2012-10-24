GLFullScreen

===========================================================================
DESCRIPTION:

This sample code demonstrates OpenGL drawing to the entire screen. 

Mac OS X 10.6 and later offer a simplified mechanism to create full-screen contexts. Earlier versions of Mac OS require additional work to capture the display and set up a special context.

When in the window mode, 
	press the "Go FullScreen" button to switch to the full-screen mode;
When in the full-screen mode, 
	press [ESC] to switch to the window mode;
In both modes, 
	press [space] to toggle rotation of the globe;
	press [w]/[W] to toggle wireframe rendering;
	holding and dragging the mouse to change the roll angle and from which the light is coming.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.6 or later, Xcode 3.1 or later

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.6 or later

===========================================================================
PACKAGING LIST:

MainController.h
MainController.m
A controller object that handles full-screen/window modes switching and user interactions.

MyOpenGLView.h
MyOpenGLView.m
An NSView subclass that delegates to separate "scene" and "controller" objects for OpenGL rendering and input event handling.

Scene.h
Scene.m
A delegate object used by MyOpenGLView and MainController to render a simple scene.

Texture.h
Texture.m
A help class that loads an OpenGL texture from an image path.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.1
Fixed a bug. Be sure to tell the display link to stop before destroying the context.

===========================================================================
Copyright (C) 2010 Apple Inc. All rights reserved.