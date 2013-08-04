Preliminary support for Xcode 4.x
---------------------------------

***Register Eero File Types.app***

This application creates an Eero source code file Uniform Type Identifier (UTI) and registers it with the system. This allows files with extensions `.eero` and `.ero` to be recognized as source code files, including from the Finder and within Xcode. It can be copied to any location, and only needs to be run once. However, the application should not be deleted, since it contains the UTI export and associated icons.


***Eero.xcplugin***

This Xcode 4.x plugin adds support for Eero's custom clang compiler, making it selectable in the project build settings. It assumes the compiler binaries are installed at `/usr/local/eerolanguage/` (use the `--prefix` option when configuring/building llvm/clang).

To install the plugin, simply copy the bundle to ``~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/``. 

Application *Register Eero File Types.app* should have been run (just once) prior to using Eero source code files in a build. They will be recognized as source files, including by the compiler, linker, and from within the debugger (e.g. breakpoints and stepping work).


***Colorizer***

This script adds basic syntax colorizing for Eero source files to Xcode. It also enables code-folding based on indentation levels.


**Limitations**

* Syntax colorizing is limited to lexical (keyword-based) parsing. Semantic recognition of types, functions, etc., is not supported.
* Autocompletion is not fully supported. Xcode will autocomplete certain identifiers, but there isn't full recognition of classes and their methods.
* "Live issues" (on-the-fly compiling) is not currently supported.
