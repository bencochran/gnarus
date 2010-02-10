//
//  LiveViewController.m
//  gnarus
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "LiveViewController.h"
#import <ARKit/ARKit.h>
#import "InfoBubbleController.h"
#import "LayerListViewController.h"

@implementation LiveViewController

@synthesize arViewController=_arViewController, locationManager=_locationManager,
			mapView=_mapView, toggleBarController=_toggleBarController,
			itemsToLayers=_itemsToLayers;


- (id)init {
	if (self = [super init]) {
		self.wantsFullScreenLayout = NO;
		pointingDown = NO;
		lastUsedLocation = nil;
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[[UIView alloc] init] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	//self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
    self.locationManager.delegate = self;
	// Set our desired accuracy to 
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	//self.locationManager.headingFilter = kCLHeadingFilterNone;
    // When "tracking" the user, the distance filter can be used to control the frequency with which location measurements
    // are delivered by the manager. If the change in distance is less than the filter, a location will not be delivered.
    //locationManager.distanceFilter = [[setupInfo objectForKey:kSetupInfoKeyDistanceFilter] doubleValue];
	
	
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.updateInterval = 0.01;
	accelerometer.delegate = self;
	
	
#if !TARGET_IPHONE_SIMULATOR

	NSLog(@"location manager: %@", self.locationManager);

	self.arViewController = [[ARGeoViewController alloc] initWithLocationManager:self.locationManager accelerometer:accelerometer];	
	self.arViewController.delegate = self;
	
	self.mapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.view addSubview:self.mapView];
	
//	self.mapView.zoomEnabled = NO;
//	self.mapView.scrollEnabled = NO;
	self.mapView.showsUserLocation = YES;
	
	self.mapView.alpha = 0;
	
	//self.view = self.arViewController.view;
	//[arViewController release];
	
	NSLog(@"Running on device");

#else
	self.arViewController = nil;
	self.mapView = nil;
	
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
	
	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *addButtonImage = [UIImage imageNamed:@"plusButton.png"];
	[addButton setImage:addButtonImage forState:UIControlStateNormal];
	addButton.frame = CGRectMake(282, 7, 33, 30);
	addButton.alpha = 0.65;
	[addButton addTarget:self action:@selector(didSelectPlus:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:addButton];
	
	// Add toggle bar
	self.toggleBarController = [[[GNToggleBarController alloc] init] autorelease];
	self.toggleBarController.delegate = self;
	
	[self.view addSubview:self.toggleBarController.view];
	
	self.itemsToLayers = [NSMutableDictionary dictionary];
	
	CGRect barFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height - 58, self.view.frame.size.width, 58);
	self.toggleBarController.view.frame = barFrame;

	// Instead of initializing the items and layers this way, we'll be
	// unarchiving archived copies of items/layers using the NSCoder protocol
	// specification
	// see http://developer.apple.com/iphone/library/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/Reference/Reference.html
	// or lecture 9 of the Stanford class
	GNLayer *layer = [[[CarletonLayer alloc] init] autorelease];
	GNToggleItem *item = [[[GNToggleItem alloc] initWithTitle:[layer name] image:[layer getIcon]] autorelease];
	[self.toggleBarController addToggleItem:item];
	[self.itemsToLayers setObject:layer forKey:item];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	
	layer = [[[FoodLayer alloc] init] autorelease];
	item = [[[GNToggleItem alloc] initWithTitle:[layer name] image:[layer getIcon]] autorelease];
	[self.toggleBarController addToggleItem:item];
	[self.itemsToLayers setObject:layer forKey:item];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];	
	
	layer = [[[TweetLayer alloc] init] autorelease];
	item = [[[GNToggleItem alloc] initWithTitle:[layer name] image:[layer getIcon]] autorelease];
	[self.toggleBarController addToggleItem:item];
	[self.itemsToLayers setObject:layer forKey:item];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	
	layer = [[[WikiLayer alloc] init] autorelease];
	item = [[[GNToggleItem alloc] initWithTitle:[layer name] image:[layer getIcon]] autorelease];
	[self.toggleBarController addToggleItem:item];
	[self.itemsToLayers setObject:layer forKey:item];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	
	// Add ourself as an observer to LayerManager updates
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationsUpdated:)
												 name:GNLandmarksUpdated
											   object:[GNLayerManager sharedManager]];
	 
    [super viewDidLoad];
}

// For a GNToggleItem, return its associated GNLayer
- (GNLayer *)layerForToggleItem:(GNToggleItem*)item {
	NSLog(@"self.itemsToLayers: %@", self.itemsToLayers);
	return [self.itemsToLayers objectForKey:item];
}

// Return the list of layers as the user has sorted them
// TODO: This needs to actually obey user order
- (NSArray *)userOrderedLayers {
	return [[GNLayerManager sharedManager] layers];
}

// For a GNLandmark, return an array of its active layers sorted according to
// the order specified by the user using the GNToggleBar
- (NSArray *)sortedLayersForLandmark:(GNLandmark *)landmark {
	// Copy the main (ordered) array of layers from the toggle bar then filter
	// it based on whether or not each ayer is in the landmark's active layer
	// list
	NSMutableArray* returnArray = [NSMutableArray array];
	
	NSArray* activeLayers = landmark.activeLayers;
	
	GNLayer* layer;
	
	for (GNToggleItem* item in [self.toggleBarController activeToggleItems]) {
		layer = [self layerForToggleItem:item];
		if ([activeLayers containsObject:layer]) {
			[returnArray addObject:item];
		}
	}
	
	return returnArray;
}

#pragma mark Toggle Bar Delegate

// When items are toggled, let the layer manager know about it
- (void)toggleBarController:(GNToggleBarController *)toggleBarController toggleItem:(GNToggleItem *)toggleItem changedToState:(BOOL)active {
	GNLayer *layer = [self layerForToggleItem:toggleItem];

	[[GNLayerManager sharedManager] setLayer:layer active:active];
	
	// Update our landmarks
	[[GNLayerManager sharedManager] updateWithPreviousLocation];
}


- (void)locationsUpdated:(NSNotification *)note {	
	NSArray *landmarks = [note.userInfo objectForKey:@"landmarks"];

	// By default we'll mark all location for removal
	NSMutableArray *locationsToRemove = [NSMutableArray arrayWithArray:self.arViewController.locations];
	
	// We'll do the same for annotations, marking them for removal by default
	NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
	
	// Never remove the userLocation annotation
	[annotationsToRemove removeObject:self.mapView.userLocation];

	// Set up a region centered on the user, initialize its span to be 0
	MKCoordinateRegion region;
	region.center = self.arViewController.centerLocation.coordinate;
	region.span.latitudeDelta = 0;
	region.span.longitudeDelta = 0;

	
	for (GNLandmark *landmark in landmarks) {
		
		if ([locationsToRemove containsObject:landmark]) {
			// Don't remove locations that are still around
			[locationsToRemove removeObject:landmark];
		} else {
			// But if it wasn't going to be removed that means we need to
			// add it.
			[self.arViewController addLocation:landmark withTitle:landmark.name];
		}


		// Use the same logic for annotations that we use for locations in the
		// ARView
		if ([annotationsToRemove containsObject:landmark]) {
			[annotationsToRemove removeObject:landmark];
		} else {
			[self.mapView addAnnotation:landmark];
		}
		
		// For the region's span, compute the delta-lat/lon from each coordinate
		// to the center, double it (since the center's in, well, the center),
		// and make it the official delta-lat/lon if it's larger than the
		// previous value
		region.span.latitudeDelta = MAX(region.span.latitudeDelta,
										fabs(region.center.latitude - landmark.coordinate.latitude) * 2 + 0.002);
		region.span.longitudeDelta = MAX(region.span.longitudeDelta,
										fabs(region.center.longitude - landmark.coordinate.longitude) * 2 + 0.002);
	}
	
	// Finally, remove locations that actually don't exist anymore
	[self.arViewController removeLocations:locationsToRemove];
	
	// Finally, remove annotations that actually don't exist anymore
	[self.mapView removeAnnotations:annotationsToRemove];
	
	// Only if we computed a span do we actually go to that region
	if (region.span.latitudeDelta > 0 && region.span.longitudeDelta > 0) {
		[self.mapView setRegion:region animated:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Put the ARKit view at the bottom of the view hierarchy
	[self.view insertSubview:self.arViewController.view atIndex:0];
	
	[self.arViewController viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:animated];
	
    // Once configured, the location manager must be "started".
    [self.locationManager startUpdatingLocation];
	[self.arViewController startListening];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.arViewController viewDidAppear:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self.locationManager stopUpdatingLocation];
	
	// Stop locationManager from listening
	[self.arViewController viewWillDisappear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
	[self.arViewController.cameraController dismissModalViewControllerAnimated:NO];
	[self.arViewController.view removeFromSuperview];
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
	[viewController release];
}

- (BOOL)shouldAutorotateViewsToInterfaceOrientation:(UIInterfaceOrientation)possibleOrientation {
    return (possibleOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
	[lastUsedLocation release];
	
    [super dealloc];
}

#pragma mark Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    // Test that the horizontal accuracy does not indicate an invalid
	// measurement
    if (newLocation.horizontalAccuracy < 0) return;
	
    // Test the age of the location measurement to determine if the measurement
	// is cached
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;

	// Update the ARViewController's center with every location update
	self.arViewController.centerLocation = newLocation;

	NSLog(@"newLocation: %@", newLocation);
				
	// If the last used location is set, is withing 10 meters of the new
	// location and was stored within 5 minutes of the new location, skip
	// updating our layer manager.
	if (lastUsedLocation != nil && [lastUsedLocation getDistanceFrom:newLocation] < 10 && -[lastUsedLocation.timestamp timeIntervalSinceDate:newLocation.timestamp] < 60 * 5) {
		NSLog(@"Ignoring");
		return;
	}
	NSLog(@"Using");
	
	// Release the old and retain the new
	[lastUsedLocation release];
	lastUsedLocation = [newLocation retain];
	
	[[GNLayerManager sharedManager] updateToCenterLocation:newLocation];
	
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.5;
	span.longitudeDelta = 0.5;
	region.center = newLocation.coordinate;
	region.span = span;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"error: %@", error);

    // The location "unknown" error simply means the manager is currently unable
	// to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
		/// Give an alert about this.
        //[self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

#pragma mark Accelerometer Manager

#define kFilteringFactor 0.05

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {

	if (acceleration.z < -0.8 && !pointingDown) {
		pointingDown = YES;
		
		[UIView beginAnimations:@"ShowMap" context:nil];
		[UIView setAnimationDuration:0.5];
		self.mapView.alpha = 1;
		[UIView commitAnimations];
		NSLog(@"now facing down");
	} else if (acceleration.z > -0.5 && pointingDown) {
		pointingDown = NO;
		
		[UIView beginAnimations:@"ShowMap" context:nil];
		[UIView setAnimationDuration:0.5];
		self.mapView.alpha = 0;
		[UIView commitAnimations];
		NSLog(@"now facing up");
	}
}

#pragma mark ARKit Delegate

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate {
	ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate *)coordinate;
	if (geoCoordinate.geoLocation != nil) {
		GNLandmark *landmark = (GNLandmark *)geoCoordinate.geoLocation;
		if (landmark.name != nil) {
			InfoBubbleController *infoBubbleController = [InfoBubbleController bubbleControllerForLandmark:landmark];
			
			[[NSNotificationCenter defaultCenter] addObserver:self
													 selector:@selector(didSelectLandmark:)
														 name:GNSelectedLandmark
													   object:landmark];

			// infoBubbleController needs to stick around so we retain it
			// this should be done in a better way as we're currently leaking
			// memory here
			[infoBubbleController retain];
			return infoBubbleController.view;
		}
	}
	return nil;
//
//	InfoBubbleController *infoBubbleController = [InfoBubbleController bubbleForLandmark:coordinate.geoLandmark];
//	InfoBubbleController *infoBubbleController = [[[InfoBubbleController alloc] init] autorelease];
//	infoBubbleController.title = coordinate.title;
//	return infoBubbleController.view;	
}

- (void)didSelectLandmark:(NSNotification *)note {
	GNLandmark *landmark = (GNLandmark *)note.object;
	if (landmark.activeLayers.count > 1) {
		// If we have more than one active layer for that landmark, give us a
		// list of layers to drill down in to
		LayerListViewController *layerList = [[LayerListViewController alloc] initWithLandmark:landmark];
		[self.navigationController pushViewController:layerList animated:YES];
		[layerList release];
	} else {
		// Otherwise, take us straight into the ViewController for the only
		// layer
		GNLayer *layer = [landmark.activeLayers objectAtIndex:0];
		UIViewController *viewController = [layer viewControllerForLandmark:landmark];
		[self.navigationController pushViewController:viewController animated:YES];
	}

}

- (void)didSelectPlus:(id)sender {
	
	GNAddLandmarkMapViewController *landmarkMapViewController = [[GNAddLandmarkMapViewController alloc]
																 initWithNibName:@"GNAddLandmarkMapViewController" bundle:nil centerLocation:lastUsedLocation.coordinate];
	landmarkMapViewController.layers = self.userOrderedLayers;
	[self.navigationController pushViewController:landmarkMapViewController animated:YES];
	[landmarkMapViewController release];

}

@end