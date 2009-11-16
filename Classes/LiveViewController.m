//
//  LiveViewController.m
//  gnarus
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "LiveViewController.h"
#import <GnarusToggleBar/GnarusToggleBar.h>
#import <ARKit/ARKit.h>
#import "InfoBubbleController.h"

@implementation LiveViewController

@synthesize arViewController=_arViewController, locationManager=_locationManager;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.wantsFullScreenLayout = NO;
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[[UIView alloc] init] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
#if !TARGET_IPHONE_SIMULATOR

	self.arViewController = [[ARGeoViewController alloc] init];	
	self.arViewController.delegate = self;
	//self.arViewController.wantsFullScreenLayout = NO;
	
	NSMutableArray *tempLocationArray = [[NSMutableArray alloc] initWithCapacity:10];
	CLLocation *tempLocation;
	ARGeoCoordinate *tempCoordinate;
	
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath;
	NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	plistPath = [rootPath stringByAppendingFormat:@"Locations.plist"];
	if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
		plistPath = [[NSBundle mainBundle] pathForResource:@"Locations" ofType:@"plist"];
	}
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSArray *temp = (NSArray *)[NSPropertyListSerialization propertyListFromData:plistXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	if (!temp) {
		NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
	}
	
	NSNumber *lat;
	NSNumber *lon;
	
	NSDictionary *locationDict;
	for (locationDict in temp) {
		NSLog(@"Lat: %@, Lon %@, %@", [locationDict objectForKey:@"latitude"], [locationDict objectForKey:@"longitude"], [locationDict objectForKey:@"name"]);
		
		lat = [locationDict objectForKey:@"latitude"];
		lon = [locationDict objectForKey:@"longitude"];
		
		tempLocation = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];		
		
		tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation];
		tempCoordinate.title = [locationDict objectForKey:@"name"];
		
		[tempLocationArray addObject:tempCoordinate];
		[tempLocation release];
	}	
	
	[self.arViewController addCoordinates:tempLocationArray];
	[tempLocationArray release];
	
	
//	CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:44.455464206683956 longitude:-93.15729260444641];
//	self.arViewController.centerLocation = newCenter;
//	[newCenter release];
	
	[self.arViewController startListening];
	[self.view addSubview:self.arViewController.view];
	//[arViewController release];
	
	NSLog(@"Running on device");

#else
	self.arViewController = nil;
	
	// Add image
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	imageView.image = [UIImage imageNamed:@"bg.jpg"];
	[self.view addSubview:imageView];
	
	// Add an info bubble
	InfoBubbleController *infoBubbleController = [[[InfoBubbleController alloc] init] autorelease];
	infoBubbleController.title = @"Memorial Hall";
	infoBubbleController.view.center = self.view.center;
	[self.view addSubview:infoBubbleController.view];	
	
	NSLog(@"Running in simulator");
#endif	
	// Add toggle bar
	GNToggleBarController *toggleBarController = [[[GNToggleBarController alloc] init] autorelease];
	[self.view addSubview:toggleBarController.view];
	CGRect barFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height - 58, self.view.frame.size.width, 58);
	toggleBarController.view.frame = barFrame;

	GNToggleItem *item = [[[GNToggleItem alloc] initWithTitle:@"Sports" image:[UIImage imageNamed:@"sports.png"]] autorelease];
	[toggleBarController addQuickToggleItem:item];
	
	item = [[[GNToggleItem alloc] initWithTitle:@"Trees" image:[UIImage imageNamed:@"trees.png"]] autorelease];
	[toggleBarController addQuickToggleItem:item];
	
	item = [[[GNToggleItem alloc] initWithTitle:@"Food" image:[UIImage imageNamed:@"food.png"]] autorelease];
	[toggleBarController addQuickToggleItem:item];
	
	item = [[[GNToggleItem alloc] initWithTitle:@"Gas" image:[UIImage imageNamed:@"gas.png"]] autorelease];
	[toggleBarController addQuickToggleItem:item];
	
	item = [[[GNToggleItem alloc] initWithTitle:@"Academic" image:[UIImage imageNamed:@"academic.png"]] autorelease];
	[toggleBarController addQuickToggleItem:item];
	
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.arViewController viewWillAppear:NO];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
	
    self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
	// Set our desired accuracy to 
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    // When "tracking" the user, the distance filter can be used to control the frequency with which location measurements
    // are delivered by the manager. If the change in distance is less than the filter, a location will not be delivered.
    //locationManager.distanceFilter = [[setupInfo objectForKey:kSetupInfoKeyDistanceFilter] doubleValue];
    // Once configured, the location manager must be "started".
    [self.locationManager startUpdatingLocation];	
}

- (void)viewDidAppear:(BOOL)animated {
	[self.arViewController viewDidAppear:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.arViewController viewWillDisappear:NO];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)buttonClick:(id)sender {

	UIViewController *viewController = [[UIViewController alloc] init];
	viewController.title = @"Hello";

	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, 21)] autorelease];
	label.text = @"Hello, world";
	label.center = viewController.view.center;
	label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[viewController.view addSubview:label];

	[self.navigationController pushViewController:viewController animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[self.arViewController viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[_locationManager release];
	[_arViewController release];
	
    [super dealloc];
}

#pragma mark Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // Test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
	
    // Test the age of the location measurement to determine if the measurement is cached
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;

	// Update the ARViewController's center
	self.arViewController.centerLocation = newLocation;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
		/// Give an alert about this.
        //[self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

#pragma mark ARKit Delegate

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate {
	InfoBubbleController *infoBubbleController = [[[InfoBubbleController alloc] init] autorelease];
	infoBubbleController.title = coordinate.title;
	//infoBubbleController.view.center = self.view.center;
	return infoBubbleController.view;	
}

@end
