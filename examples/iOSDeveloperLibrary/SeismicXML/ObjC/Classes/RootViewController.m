/*
     File: RootViewController.m
 Abstract: View controller for displaying the earthquake list.
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

#import "RootViewController.h"
#import "Earthquake.h"

@implementation RootViewController

@synthesize earthquakeList;

#pragma mark -

- (void)dealloc {
    [earthquakeList release];
    [dateFormatter release];
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.earthquakeList = [NSMutableArray array];
    
    // The table row height is not the standard value. Since all the rows have the same height,
    // it is more efficient to set this property on the table, rather than using the delegate
    // method -tableView:heightForRowAtIndexPath:
    //
    self.tableView.rowHeight = 48.0;
    
    // KVO: listen for changes to our earthquake data source for table view updates
    [self addObserver:self forKeyPath:@"earthquakeList" options:0 context:NULL];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.earthquakeList = nil;
    
    [self removeObserver:self forKeyPath:@"earthquakeList"];
}

// On-demand initializer for read-only property.
- (NSDateFormatter *)dateFormatter {
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    return dateFormatter;
}

// Based on the magnitude of the earthquake, return an image indicating its seismic strength.
- (UIImage *)imageForMagnitude:(CGFloat)magnitude {	
	if (magnitude >= 5.0) {
		return [UIImage imageNamed:@"5.0.png"];
	}
	if (magnitude >= 4.0) {
		return [UIImage imageNamed:@"4.0.png"];
	}
	if (magnitude >= 3.0) {
		return [UIImage imageNamed:@"3.0.png"];
	}
	if (magnitude >= 2.0) {
		return [UIImage imageNamed:@"2.0.png"];
	}
	return nil;
}


#pragma mark -
#pragma mark KVO support

- (void)insertEarthquakes:(NSArray *)earthquakes
{
    // this will allow us as an observer to notified (see observeValueForKeyPath)
    // so we can update our UITableView
    //
    [self willChangeValueForKey:@"earthquakeList"];
    [self.earthquakeList addObjectsFromArray:earthquakes];
    [self didChangeValueForKey:@"earthquakeList"];
}

// listen for changes to the earthquake list coming from our app delegate.
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDelegate

// The number of rows is equal to the number of earthquakes in the array.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [earthquakeList count];
}

// The cell uses a custom layout, but otherwise has standard behavior for UITableViewCell.
// In these cases, it's preferable to modify the view hierarchy of the cell's content view, rather
// than subclassing. Instead, view "tags" are used to identify specific controls, such as labels,
// image views, etc.
//
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Each subview in the cell will be identified by a unique tag.
    static NSUInteger const kLocationLabelTag = 2;
    static NSUInteger const kDateLabelTag = 3;
    static NSUInteger const kMagnitudeLabelTag = 4;
    static NSUInteger const kMagnitudeImageTag = 5;
    
    // Declare references to the subviews which will display the earthquake data.
    UILabel *locationLabel = nil;
    UILabel *dateLabel = nil;
    UILabel *magnitudeLabel = nil;
    UIImageView *magnitudeImage = nil;
    
	static NSString *kEarthquakeCellID = @"EarthquakeCellID";    
  	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEarthquakeCellID];
	if (cell == nil) {
        // No reusable cell was available, so we create a new cell and configure its subviews.
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:kEarthquakeCellID] autorelease];
        
        locationLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 3, 190, 20)] autorelease];
        locationLabel.tag = kLocationLabelTag;
        locationLabel.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:locationLabel];
        
        dateLabel = [[[UILabel alloc] initWithFrame:CGRectMake(10, 28, 170, 14)] autorelease];
        dateLabel.tag = kDateLabelTag;
        dateLabel.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:dateLabel];

        magnitudeLabel = [[[UILabel alloc] initWithFrame:CGRectMake(277, 9, 170, 29)] autorelease];
        magnitudeLabel.tag = kMagnitudeLabelTag;
        magnitudeLabel.font = [UIFont boldSystemFontOfSize:24];
        magnitudeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:magnitudeLabel];
        
        magnitudeImage = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"5.0.png"]] autorelease];
        CGRect imageFrame = magnitudeImage.frame;
        imageFrame.origin = CGPointMake(180, 2);
        magnitudeImage.frame = imageFrame;
        magnitudeImage.tag = kMagnitudeImageTag;
        magnitudeImage.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [cell.contentView addSubview:magnitudeImage];
    } else {
        // A reusable cell was available, so we just need to get a reference to the subviews
        // using their tags.
        //
        locationLabel = (UILabel *)[cell.contentView viewWithTag:kLocationLabelTag];
        dateLabel = (UILabel *)[cell.contentView viewWithTag:kDateLabelTag];
        magnitudeLabel = (UILabel *)[cell.contentView viewWithTag:kMagnitudeLabelTag];
        magnitudeImage = (UIImageView *)[cell.contentView viewWithTag:kMagnitudeImageTag];
    }
    
    // Get the specific earthquake for this row.
	Earthquake *earthquake = [earthquakeList objectAtIndex:indexPath.row];
    
    // Set the relevant data for each subview in the cell.
    locationLabel.text = earthquake.location;
    dateLabel.text = [NSString stringWithFormat:@"%@", [self.dateFormatter stringFromDate:earthquake.date]];
    magnitudeLabel.text = [NSString stringWithFormat:@"%.1f", earthquake.magnitude];
    magnitudeImage.image = [self imageForMagnitude:earthquake.magnitude];

	return cell;
}

// When the user taps a row in the table, display the USGS web page that displays details of the
// earthquake they selected.
//
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:
            NSLocalizedString(@"External App Sheet Title",
                              @"Title for sheet displayed with options for displaying Earthquake data in other applications")
                               delegate:self
                      cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
                 destructiveButtonTitle:nil
                      otherButtonTitles:NSLocalizedString(@"Show USGS Site in Safari", @"Show USGS Site in Safari"),
                                        NSLocalizedString(@"Show Location in Maps", @"Show Location in Maps"),
                                        nil];
    [sheet showInView:self.view];
    [sheet release];
}

// Called when the user selects an option in the sheet. The sheet will automatically be dismissed.
- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    Earthquake *earthquake = (Earthquake *)[earthquakeList objectAtIndex:selectedIndexPath.row];
    switch (buttonIndex) {
        case 0: {
            NSURL *webLink = [earthquake USGSWebLink];
            [[UIApplication sharedApplication] openURL:webLink];
        } break;
        case 1: {
            NSString *mapsQuery =
                [NSString stringWithFormat:@"http://maps.google.com/maps?z=6&t=h&ll=%f,%f",
                                            earthquake.latitude, earthquake.longitude];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mapsQuery]];
        } break;
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}

@end