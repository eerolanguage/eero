

To build the Eero version (using the Eero patched version of clang, of course):

$  clang -Wall -O0 -g -fobjc-gc -dynamiclib -o CurrentLineHighlighter.dylib XCodeCurrentLineHighlighter.ero -framework Cocoa


To build the Objective-C version, you can use either clang or gcc, and use either the Xcode project or the command line:

$  clang -Wall -O0 -g -fobjc-gc -dynamiclib -o CurrentLineHighlighter.dylib XCodeCurrentLineHighlighter.m -framework Cocoa

$  gcc -Wall -O0 -g -fobjc-gc -dynamiclib -o CurrentLineHighlighter.dylib XCodeCurrentLineHighlighter.m -framework Cocoa


Once built, copy CurrentLineHighlighter.dylib to a directory of your choice, and perform the following commands. Make sure to
use the appropriate locations of your Xcode application and the highlighter library. Also make sure Xcode is not running while 
issuing these commands. They do not need to be run as root unless some of these files are in system directories (not normally the case).

$  defaults write /PATH/TO/Xcode.app/Contents/Info LSEnvironment -dict DYLD_INSERT_LIBRARIES /PATH/TO/CurrentLineHighlighter.dylib

$  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -v -f /PATH/TO/Xcode.app


Or, to simply run Xcode 4 (with the library) from the command line (if you don't want to modify your Xcode.app bundle):

$  DYLD_INSERT_LIBRARIES=/PATH/TO/CurrentLineHighlighter.dylib open /PATH/TO/Xcode.app


NOTE: Only tested with Xcode 4.0.2.



