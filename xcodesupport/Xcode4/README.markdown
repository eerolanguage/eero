Preliminary support for Xcode 4.x
---------------------------------

***Register Eero File Types.app***

This application creates an Eero source code file Uniform Type Identifier (UTI) and registers it with the system. This allows files with extensions `.eero` and `.ero` to be recognized as source code files, including from the Finder and within Xcode. It can be copied to any location, and only needs to be run once. However, the application should not be deleted, since it contains the UTI export and associated icon files.


***Eero.xcplugin***

This Xcode 4.x plugin adds support for Eero's custom clang compiler, making it selectable in the project build settings. It assumes the compiler binaries are installed at `/usr/local/eerolanguage/` (use the `--prefix` option when configuring/building llvm/clang).

To install the plugin, simply copy the bundle to ``~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/``. 

Application *Register Eero File Types.app* should have been run (just once) prior to using Eero source code files in a build. They will be recognized as source files, including by the compiler, linker, and from within the debugger (e.g. breakpoints and stepping work).

**Limitations**

* Syntax colorizing is currently very limited -- the "Generic" source code highlighting is chosen for Eero source files by default. This can be overridden manually to any supported language (Objective-C++ is suggested), but no definition for Eero is provided at this time.
* Autocompletion is not supported.
* "Live issues" (only-the-fly syntax checking) is not currently supported.
