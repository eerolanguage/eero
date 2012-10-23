SeismicXML

===========================================================================
DESCRIPTION:

The SeismicXML sample application demonstrates how to use NSXMLParser to parse XML data.
When you launch the application it downloads and parses an RSS feed from the United States Geological Survey (USGS) that provides data on recent earthquakes around the world. It displays the location, date, and magnitude of each earthquake, along with a color-coded graphic that indicates the severity of the earthquake. The XML parsing occurs on a background thread and updates the earthquakes table view with batches of parsed objects.

The USGS feed is at http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml and includes all recent magnitude 2.5 and greater earthquakes world-wide, representing each earthquake with an <entry> element, in the following form:
 
<entry>
    <id>urn:earthquake-usgs-gov:us:2008rkbc</id>
    <title>M 5.8, Banda Sea</title>
    <updated>2008-04-29T19:10:01Z</updated>
    <link rel="alternate" type="text/html" href="/eqcenter/recenteqsww/Quakes/us2008rkbc.php"/>
    <link rel="related" type="application/cap+xml" href="/eqcenter/catalogs/cap/us2008rkbc"/>
    <summary type="html">
        <img src="http://earthquake.usgs.gov/images/globes/-5_130.jpg" alt="6.102&#176;S 127.502&#176;E" align="left" hspace="20" /><p>Tuesday, April 29, 2008 19:10:01 UTC<br>Wednesday, April 30, 2008 04:10:01 AM at epicenter</p><p><strong>Depth</strong>: 395.20 km (245.57 mi)</p>
    </summary>
    <georss:point>-6.1020 127.5017</georss:point>
    <georss:elev>-395200</georss:elev>
    <category label="Age" term="Past hour"/>
</entry>

NSXMLParser is an "event-driven" parser. This means that it makes a single pass over the XML data and calls back to its delegate with "events". These events include the beginning and end of elements, parsed character data, errors, and more. In this sample, the application delegate, an instance of the "SeismicXMLAppDelegate" class, also implements the delegate methods for the parser object. In these methods, Earthquake objects are instantiated and their properties are set, according to the data provided by the parser. For some data, additional work is required - numbers extracted from strings, or date objects created from strings. 


===========================================================================
BUILD REQUIREMENTS

iOS SDK 4.0

===========================================================================
RUNTIME REQUIREMENTS

iOS OS 3.2 or later

===========================================================================
PACKAGING LIST

SeismicXMLAppDelegate
Delegate for the application, initiates the download of the XML data and parses the Earthquake objects at launch time.

Earthquake
The model class that stores the information about an earthquake.

RootViewController
A UITableViewController subclass that manages the table view.

ParseOperation
The NSOperation class used to perform the XML parsing of earthquake data.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS

Version 2.3
- Now using NSOperation to perform the XML parsing, silencing any parse aborting errors.

Version 2.1
- Update artwork and added NSXMLParserDelegate protocol.

Version 2.0
- Updated for and tested with iOS 4.0 SDK.

Version 1.9
- Proper formatting of dates, fixed earthquake reporting URLs due to changes in USGS page, removed unused frameworks, improved error reporting, now using KVO for table view updates.

Version 1.8
- Added separate use of NSURLConnection to asynchronously download data instead of using NSXMLParser -initWithContentsOfURL. Upgraded for 3.0 SDK due to deprecated APIs.

Version 1.7
- Updated for and tested with iPhone OS 2.0. First public release.

Version 1.6
- Updated for GM release.
- Fixed a memory leak in SeismicXMLAppDelegate.m.

Version 1.5
- Updated for Beta 7.
- Fixed memory leaks in XMLReader.m.
- Now uses the SystemConfiguration framework to determine if the RSS feed provider is available and displays a message in the table view if it's not.

Version 1.4
- Updated for Beta 6.
- Added LSRequiresIPhoneOS key to Info.plist
- The custom table view cell add subviews to its content view rather than drawing them directly.

Version 1.3
- Updated for Beta 5.
- Removed the XML-to-Objective-C object mapping to simplify the sample.
- Moved the XML parsing to a background thread.

Version 1.2
- Updated for Beta 4.
- Now uses NSXMLParser to parse XML.
- Removed unused XML parsing classes.

Version 1.1
- Updated for Beta 3.
- Updated table view API.
- Add icon and replaced Default.png file.
- Removed unit tests.
- Removed unused framework.

===========================================================================
Copyright (C) 2008-2010 Apple Inc. All rights reserved.