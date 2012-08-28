#!/usr/bin/env bash

# Based on a shell script provided by the Go Programming Language project
# Copyright 2012 The Go Authors.  All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Provides a way for an Eero language specification to be installed for Xcode 4.x. to
# enable syntax coloring.
#
# Works best when used in conjunction with the Eero.xcplugin (provides automatic detection of file type)
#
set -e
	
# Assumes Xcode 4+.
XCODE_MAJOR_VERSION=`xcodebuild -version | awk 'NR == 1 {print substr($2,1,1)}'`
if [ "$XCODE_MAJOR_VERSION" -lt "4" ]; then
	echo "Xcode 4.x not found."
	exit 1
fi

# DVTFOUNDATION_DIR may vary depending on Xcode setup. Change it to reflect
# your current Xcode setup. Find suitable path with e.g.:
#
#	find / -type f -name 'DVTFoundation.xcplugindata' 2> /dev/null
#
# Example of DVTFOUNDATION_DIR's from "default" Xcode 4.x setups;
#
#	Xcode 4.1: /Developer/Library/PrivateFrameworks/DVTFoundation.framework/Versions/A/Resources/
#	Xcode 4.3: /Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/
#
DVTFOUNDATION_DIR="/Applications/Xcode.app/Contents/SharedFrameworks/DVTFoundation.framework/Versions/A/Resources/"
PLUGINDATA_FILE="DVTFoundation.xcplugindata"

PLISTBUDDY=/usr/libexec/PlistBuddy
PLIST_FILE=tmp.plist

# Provide means of deleting the Eero entry from the plugindata file.
if [ "$1" = "--delete-entry" ]; then
	echo "Removing Eero language specification entry."
	$PLISTBUDDY -c "Delete :plug-in:extensions:Xcode.SourceCodeLanguage.Eero" $DVTFOUNDATION_DIR/$PLUGINDATA_FILE
	echo "Run 'sudo rm -rf /var/folders/*' and restart Xcode to update change immediately."
	exit 0
fi

EERO_VERSION="1.0"

EERO_LANG_ENTRY="
	<?xml version=\"1.0\" encoding=\"UTF-8\"?>
	<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
	<plist version=\"1.0\">
		<dict>
			<key>Xcode.SourceCodeLanguage.Eero</key>
			<dict>
				<key>conformsTo</key>
				<array>
					<dict>
						<key>identifier</key>
						<string>Xcode.SourceCodeLanguage.Generic</string>
					</dict>
				</array>
				<key>documentationAbbreviation</key>
				<string>eero</string>
				<key>fileDataType</key>
				<array>
					<dict>
						<key>identifier</key>
						<string>org.eerolanguage.eero-source</string>
					</dict>
				</array>
				<key>id</key>
				<string>Xcode.SourceCodeLanguage.Eero</string>
				<key>languageName</key>
				<string>Eero</string>
				<key>languageSpecification</key>
				<string>xcode.lang.eero</string>
				<key>name</key>
				<string>The Eero Programming Language</string>
				<key>point</key>
				<string>Xcode.SourceCodeLanguage</string>
				<key>version</key>
				<string>$EERO_VERSION</string>
			</dict>
		</dict>
	</plist>
"
  
echo "Backing up plugindata file."
cp $DVTFOUNDATION_DIR/$PLUGINDATA_FILE $DVTFOUNDATION_DIR/$PLUGINDATA_FILE.bak

echo "Adding Eero language specification entry."
echo $EERO_LANG_ENTRY > $PLIST_FILE
$PLISTBUDDY -c "Merge $PLIST_FILE plug-in:extensions" $DVTFOUNDATION_DIR/$PLUGINDATA_FILE

rm -f $PLIST_FILE
 
echo "Installing Eero language specification file for Xcode."
cp Eero.xclangspec $DVTFOUNDATION_DIR

echo "Run 'sudo rm -rf /var/folders/*' and restart Xcode to update change immediately."
echo "If Eero.xcplugin is properly installed, Eero source files will be automatically detected."


