/*
     File: SeismicXMLAppDelegate.m
 Abstract: Delegate for the application, initiates the download of the XML data and parses the Earthquake objects at launch time.
  Version: 2.3
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2010 Apple Inc. All Rights Reserved.
 
 */

#import "SeismicXMLAppDelegate.h"
#import "RootViewController.h"
#import "Earthquake.h"
#import "ParseOperation.h"

// this framework was imported so we could use the kCFURLErrorNotConnectedToInternet error code
#import <CFNetwork/CFNetwork.h>


#pragma mark SeismicXMLAppDelegate () 

// forward declarations
@interface SeismicXMLAppDelegate ()

@property (nonatomic, retain) NSURLConnection *earthquakeFeedConnection;
@property (nonatomic, retain) NSMutableData *earthquakeData;    // the data returned from the NSURLConnection
@property (nonatomic, retain) NSOperationQueue *parseQueue;     // the queue that manages our NSOperation for parsing earthquake data

- (void)addEarthquakesToList:(NSArray *)earthquakes;
- (void)handleError:(NSError *)error;
@end


#pragma mark -
#pragma mark SeismicXMLAppDelegate

@implementation SeismicXMLAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;
@synthesize earthquakeFeedConnection;
@synthesize earthquakeData;
@synthesize parseQueue;


- (void)dealloc {
    [earthquakeFeedConnection cancel];
    [earthquakeFeedConnection release];
    
    [earthquakeData release];
    [navigationController release];
    [rootViewController release];
    [window release];
    
    [parseQueue release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kAddEarthquakesNotif object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEarthquakesErrorNotif object:nil];
    
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Add the navigation view controller to the window.
    [window addSubview:navigationController.view];
    
    // Use NSURLConnection to asynchronously download the data. This means the main thread will not
    // be blocked - the application will remain responsive to the user. 
    //
    // IMPORTANT! The main thread of the application should never be blocked!
    // Also, avoid synchronous network access on any thread.
    //
    static NSString *feedURLString = @"http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml";
    NSURLRequest *earthquakeURLRequest =
    [NSURLRequest requestWithURL:[NSURL URLWithString:feedURLString]];
    self.earthquakeFeedConnection =
    [[[NSURLConnection alloc] initWithRequest:earthquakeURLRequest delegate:self] autorelease];
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development.
    // If the URL is more dynamic, then you should implement a more flexible validation technique,
    // and be able to both recover from errors and communicate problems to the user in an
    // unobtrusive manner.
    NSAssert(self.earthquakeFeedConnection != nil, @"Failure to create URL connection.");
    
    // Start the status bar network activity indicator. We'll turn it off when the connection
    // finishes or experiences an error.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    parseQueue = [NSOperationQueue new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addEarthquakes:)
                                                 name:kAddEarthquakesNotif
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(earthquakesError:)
                                                 name:kEarthquakesErrorNotif
                                               object:nil];
}


#pragma mark -
#pragma mark NSURLConnection delegate methods

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is
// how the connection object, which is working in the background, can asynchronously communicate back
// to its delegate on the thread from which it was started - in this case, the main thread.
//
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // check for HTTP status code for proxy authentication failures
    // anything in the 200 to 299 range is considered successful,
    // also make sure the MIMEType is correct:
    //
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ((([httpResponse statusCode]/100) == 2) && [[response MIMEType] isEqual:@"application/atom+xml"]) {
        self.earthquakeData = [NSMutableData data];
    } else {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:
                                  NSLocalizedString(@"HTTP Error",
                                                    @"Error message displayed when receving a connection error.")
                                                             forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"HTTP" code:[httpResponse statusCode] userInfo:userInfo];
        [self handleError:error];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [earthquakeData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    if ([error code] == kCFURLErrorNotConnectedToInternet) {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:
         NSLocalizedString(@"No Connection Error",
                           @"Error message displayed when not connected to the Internet.")
                                    forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    } else {
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.earthquakeFeedConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.earthquakeFeedConnection = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    
    // Spawn an NSOperation to parse the earthquake data so that the UI is not blocked while the
    // application parses the XML data.
    //
    // IMPORTANT! - Don't access or affect UIKit objects on secondary threads.
    //
    ParseOperation *parseOperation = [[ParseOperation alloc] initWithData:self.earthquakeData];
    [self.parseQueue addOperation:parseOperation];
    [parseOperation release];   // once added to the NSOperationQueue it's retained, we don't need it anymore
    
    // earthquakeData will be retained by the NSOperation until it has finished executing,
    // so we no longer need a reference to it in the main thread.
    self.earthquakeData = nil;
}

// Handle errors in the download by showing an alert to the user. This is a very
// simple way of handling the error, partly because this application does not have any offline
// functionality for the user. Most real applications should handle the error in a less obtrusive
// way and provide offline functionality to the user.
//
- (void)handleError:(NSError *)error {
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView =
    [[UIAlertView alloc] initWithTitle:
     NSLocalizedString(@"Error Title",
                       @"Title for alert displayed when download or parse error occurs.")
                               message:errorMessage
                              delegate:nil
                     cancelButtonTitle:@"OK"
                     otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

// Our NSNotification callback from the running NSOperation to add the earthquakes
//
- (void)addEarthquakes:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self addEarthquakesToList:[[notif userInfo] valueForKey:kEarthquakeResultsKey]];
}

// Our NSNotification callback from the running NSOperation when a parsing error has occurred
//
- (void)earthquakesError:(NSNotification *)notif {
    assert([NSThread isMainThread]);
    
    [self handleError:[[notif userInfo] valueForKey:kEarthquakesMsgErrorKey]];
}

// The NSOperation "ParseOperation" calls addEarthquakes: via NSNotification, on the main thread
// which in turn calls this method, with batches of parsed objects.
// The batch size is set via the kSizeOfEarthquakeBatch constant.
//
- (void)addEarthquakesToList:(NSArray *)earthquakes {
    
    // insert the earthquakes into our rootViewController's data source (for KVO purposes)
    [self.rootViewController insertEarthquakes:earthquakes];
}

@end