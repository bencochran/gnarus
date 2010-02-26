//
//  LiveViewController.m
//  gnarus
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "LiveViewController.h"
#import <ARKit/ARKit.h>
#import "InfoBubble.h"
#import "LayerListViewController.h"

// Private methods
@interface LiveViewController ()

- (GNLayer *)layerForToggleItem:(GNToggleItem *)item;
- (NSArray *)userOrderedLayers;
- (NSArray *)sortedLayersForLandmark:(GNLandmark *)landmark;
- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;
- (void)addConnection;
- (void)removeConnection;
- (void)didSelectPlus:(id)sender;

@end


@implementation LiveViewController

@synthesize arViewController=_arViewController, locationManager=_locationManager,
			mapView=_mapView, toggleBarController=_toggleBarController,
			itemsToLayers=_itemsToLayers;

- (id)init {
	if (self = [super init]) {
		self.wantsFullScreenLayout = YES;
		pointingDown = NO;
		lastUsedLocation = nil;
		connectionCount = 0;
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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name: UIDeviceOrientationDidChangeNotification object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];	
	
	// Listen to GNSelectedLandmark notifications from all objects
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSelectLandmark:)
												 name:GNSelectedLandmark
											   object:nil];
	
	// Listen to GNLayerUpdateFailed notifications from all objects
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(layerUpdateFailed:)
												 name:GNLayerUpdateFailed
											   object:nil];
	
	// Listen to GNLayerDidStartUpdating notifications from all objects
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(layerStartedUpdating:)
												 name:GNLayerDidStartUpdating
											   object:nil];
	
	// Listen to GNLayerDidFinishUpdating notifications from all objects
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(layerFinishedUpdating:)
												 name:GNLayerDidFinishUpdating
											   object:nil];
	
	
#if !TARGET_IPHONE_SIMULATOR
	self.arViewController = [[ARGeoViewController alloc] initWithLocationManager:self.locationManager];	
	self.arViewController.delegate = self;

#else
	self.arViewController = nil;
#endif
	
	self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
	self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	[self.view addSubview:self.mapView];
	
	//	self.mapView.zoomEnabled = NO;
	//	self.mapView.scrollEnabled = NO;
	self.mapView.showsUserLocation = YES;
	self.mapView.delegate = self;

#if !TARGET_IPHONE_SIMULATOR
	self.mapView.alpha = 0;	
#endif
	
	UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[addButton setImage:[UIImage imageNamed:@"plusButton.png"] forState:UIControlStateNormal];
	addButton.frame = CGRectMake(self.view.frame.size.width - 38, [[UIApplication sharedApplication] statusBarFrame].size.height + 7, 33, 30);
	addButton.alpha = 0.65;
	addButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
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
	// unarchiving archived copies of items/layers using the NSCoder protocol specification
	// see http://developer.apple.com/iphone/library/documentation/Cocoa/Reference/Foundation/Protocols/NSCoding_Protocol/Reference/Reference.html
	// or lecture 9 of the Stanford class
	GNLayer *layer = [[CarletonLayer alloc] init];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	[layer release];
	
	layer = [[FoodLayer alloc] init];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	[layer release];
	
	layer = [[TweetLayer alloc] init];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	[layer release];
	
	layer = [[WikiLayer alloc] init];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	[layer release];
	
	layer = [[FlickrLayer alloc] init];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	[layer release];
	
	layer = [[SportingArenasLayer alloc] init];
	[[GNLayerManager sharedManager] addLayer:layer active:NO];
	[layer release];
	
	GNToggleItem *item;
	for(layer in [[GNLayerManager sharedManager] layers]) {
		item = [[GNToggleItem alloc] initWithTitle:[layer name] image:[layer getIcon]];
		[self.toggleBarController addToggleItem:item];
		[self.itemsToLayers setObject:layer forKey:item];
		[item release];
	}
	
	// Add self as an observer to LayerManager update
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(locationsUpdated:)
												 name:GNLandmarksUpdated
											   object:[GNLayerManager sharedManager]];

    [HUDView showHUDStyle:HUDViewStyleSpinner status:@"Locating" statusDetails:nil];
	
	[super viewDidLoad];
}

// For a GNToggleItem, return its associated GNLayer
- (GNLayer *)layerForToggleItem:(GNToggleItem*)item {
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
	// it based on whether or not each ayer is in the landmark's active layer list
	NSMutableArray* returnArray = [NSMutableArray array];
	NSArray* activeLayers = [[GNLayerManager sharedManager] activeLayersForLandmark:landmark];
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
	[[GNLayerManager sharedManager] updateWithPreviousLocation];	// Update our landmarks
}

- (void)locationsUpdated:(NSNotification *)note {	
	NSArray *landmarks = [note.userInfo objectForKey:@"landmarks"];

	// By default we'll mark all locations for removal
	NSMutableArray *locationsToRemove = [NSMutableArray arrayWithArray:self.arViewController.locations];
	
	// We'll do the same for annotations, marking them for removal by default
	NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
	
	// Never remove the userLocation annotation
	[annotationsToRemove removeObject:self.mapView.userLocation];

	// Set up a region centered on the user, initialize its span to 0
	MKCoordinateRegion region;
	region.center = lastUsedLocation.coordinate;
	region.span.latitudeDelta = 0;
	region.span.longitudeDelta = 0;
	
	for (GNLandmark *landmark in landmarks) {
		
		if ([locationsToRemove containsObject:landmark]) {
			// Don't remove locations that are still around
			[locationsToRemove removeObject:landmark];
		} else {
			// But if it wasn't going to be removed
			// that means we need to add it.
			[self.arViewController addLocation:landmark withTitle:landmark.name];
		}
		
		// Use the same logic for annotations that we use
		// for locations in the ARView
		if ([annotationsToRemove containsObject:landmark]) {
			[annotationsToRemove removeObject:landmark];
		} else {
			[self.mapView addAnnotation:landmark];
		}
		
		// For the region's span, compute the delta-lat/lon from each coordinate
		// to the center, double it (since the center's in, well, the center),
		// and make it the official delta-lat/lon if it's larger than the previous value
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

- (void)layerStartedUpdating:(NSNotification *)note {
	[self addConnection];
}

- (void)layerFinishedUpdating:(NSNotification *)note {
	[self removeConnection];
}

- (void)layerUpdateFailed:(NSNotification *)note {	
//	GNLayer *layer = [note object];
	NSError *error = [[note userInfo] objectForKey:@"error"];
	
	[self removeConnection];
	[HUDView showHUDStyle:HUDViewStyleError
				   status:@"Error" 
			statusDetails:[[error userInfo] objectForKey:@"NSLocalizedDescription"]
				  forTime:3];

//	NSLog(@"Live view controller noted error: %@ from layer: %@", error, layer);
}

- (void)addConnection {
	connectionCount++;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)removeConnection {
	connectionCount--;
	if (connectionCount < 1) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	// Put the ARKit view at the bottom of the view hierarchy
	[self.view insertSubview:self.arViewController.view atIndex:0];
	
	[self.arViewController viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
	
    // Once configured, the location manager must be "started".
    [self.locationManager startUpdatingLocation];
	[self.arViewController startListening];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.arViewController viewDidAppear:NO];
	[self.arViewController updateLocations:nil];
	
	// Always update the LayerManager when the view become active again
	[[GNLayerManager sharedManager] updateWithPreviousLocation];
	
	// Because presenting the camera modally covers up the status bar, let's set
	// it to come back after a short delay.
	// This looks a little gross. But at least we have a status bar.
	//
	// TODO: Fix the status bar so it never disappears.
	// Dunno how right now though
	[self performSelector:@selector(resetStatusBar:) withObject:nil afterDelay:0.05];
}

- (void)resetStatusBar:(id)object {
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

//- (BOOL)shouldAutorotateViewsToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}

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
	[_arViewController release];
	[_mapView release];
	[_locationManager release];
	[lastUsedLocation release];
	[_toggleBarController release];
	[_itemsToLayers release];
	
    [super dealloc];
}

#pragma mark Location Manager

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {	
#if TARGET_IPHONE_SIMULATOR
	// Make the simulator put us in an interesting location.
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = 44.4624651543;
	coordinate.longitude = -93.1527388251;
	newLocation = [[[CLLocation alloc] initWithCoordinate:coordinate altitude:0 horizontalAccuracy:1 verticalAccuracy:1 timestamp:[NSDate date]] autorelease];

	CLLocationCoordinate2D oldCoordinate;
	oldCoordinate.latitude = 45.46087059486058;
	oldCoordinate.longitude = -93.1536018848419;
	oldLocation = [[[CLLocation alloc] initWithCoordinate:oldCoordinate	altitude:0 horizontalAccuracy:1 verticalAccuracy:1 timestamp:[NSDate dateWithTimeIntervalSinceNow:-100000]] autorelease];
#endif
    
	// Test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
	
    // Test the age of the location measurement to determine if the measurement is cached
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if (locationAge > 5.0) return;

	// Update the ARViewController's center with every location update
	self.arViewController.centerLocation = newLocation;

	NSLog(@"newLocation: %@", newLocation);
				
	// If the last used location is set, is withing 10 meters of the new
	// location and was stored within 5 minutes of the new location, skip
	// updating our layer manager.
	if (lastUsedLocation != nil && [lastUsedLocation getDistanceFrom:newLocation] < 10 && -[lastUsedLocation.timestamp timeIntervalSinceDate:newLocation.timestamp] < 60 * 5) {
		NSLog(@"Ignoring new location");
		return;
	}
	NSLog(@"Using new location");
	
	[HUDView dismiss];
	
	// Release the old and retain the new
	[lastUsedLocation release];
	lastUsedLocation = [newLocation retain];
	
	[[GNLayerManager sharedManager] updateToCenterLocation:newLocation];
	
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta = 0.5;
	span.longitudeDelta = 0.5;
	region.span = span;
	region.center = newLocation.coordinate;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	NSLog(@"Location manager failed with error: %@", error);
    // The location "unknown" error simply means the manager is currently unable
	// to get the location.
    if ([error code] != kCLErrorLocationUnknown) {
		/// Give an alert about this.
        //[self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
#if !TARGET_IPHONE_SIMULATOR
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if (orientation == UIDeviceOrientationFaceUp) {		
		[UIView beginAnimations:@"ShowMap" context:nil];
		[UIView setAnimationDuration:0.5];
		self.mapView.alpha = 1;
		[UIView commitAnimations];
	} else {
		[UIView beginAnimations:@"ShowMap" context:nil];
		[UIView setAnimationDuration:0.5];
		self.mapView.alpha = 0;
		[UIView commitAnimations];
	}
#endif
}

#pragma mark MapKit Delegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if (annotation == self.mapView.userLocation) {
		return nil;
	}
	
	MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"GNLiveViewMapAnnotation"];
	if (annotationView == nil) {
		annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title] autorelease];
		annotationView.pinColor = MKPinAnnotationColorRed;
		annotationView.animatesDrop = NO;
		annotationView.canShowCallout = YES;
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([control isKindOfClass:[UIButton class]]) {
		GNLandmark *landmark = (GNLandmark *)view.annotation;
		NSArray *layers = [[GNLayerManager sharedManager] activeLayersForLandmark:landmark];
		if ([layers count] > 1) {
			// If we have more than one active layer for that landmark, give us a
			// list of layers to drill down in to
			LayerListViewController *layerList = [[LayerListViewController alloc] initWithLandmark:landmark];
			[self.navigationController pushViewController:layerList animated:YES];
			[layerList release];
		} else {
			// Otherwise, take us straight into the ViewController for the only layer
			GNLayer *layer = [layers objectAtIndex:0];
			UIViewController *viewController = [layer viewControllerForLandmark:landmark];
			[self.navigationController pushViewController:viewController animated:YES];
		}
	}
}

#pragma mark ARKit Delegate

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate {
	ARGeoCoordinate *geoCoordinate = (ARGeoCoordinate *)coordinate;
	if (geoCoordinate.geoLocation != nil) {
		GNLandmark *landmark = (GNLandmark *)geoCoordinate.geoLocation;
		if (landmark.name != nil) {
			InfoBubble *bubble = [InfoBubble infoBubbleWithLandmark:landmark];
			return bubble;
//			
//			InfoBubbleController *infoBubbleController = [InfoBubbleController bubbleControllerForLandmark:landmark];
//			
//			[[NSNotificationCenter defaultCenter] addObserver:self
//													 selector:@selector(didSelectLandmark:)
//														 name:GNSelectedLandmark
//													   object:landmark];
//
//			// infoBubbleController needs to stick around so we retain it
//			// this should be done in a better way as we're currently leaking
//			// memory here
//			[infoBubbleController retain];
//			return infoBubbleController.view;
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
	NSArray *layers = [[GNLayerManager sharedManager] activeLayersForLandmark:landmark];
	if ([layers count] > 1) {
		// If we have more than one active layer for that landmark, give us a
		// list of layers to drill down in to
		LayerListViewController *layerList = [[LayerListViewController alloc] initWithLandmark:landmark];
		[self.navigationController pushViewController:layerList animated:YES];
		[layerList release];
	} else {
		// Otherwise, take us straight into the ViewController for the only layer
		GNLayer *layer = [layers objectAtIndex:0];
		UIViewController *viewController = [layer viewControllerForLandmark:landmark];
		[self.navigationController pushViewController:viewController animated:YES];
	}
}

// Called when the "+" button in the upper right corner of the view is pressed:
// adds a GNAddLandmarkMapViewController to the navigationController stack
- (void)didSelectPlus:(id)sender {
	GNAddLandmarkMapViewController *landmarkMapViewController = [[GNAddLandmarkMapViewController alloc]
																 initWithNibName:@"GNAddLandmarkMapViewController" bundle:nil centerLocation:lastUsedLocation.coordinate];
	landmarkMapViewController.layers = self.userOrderedLayers;
	[self.navigationController pushViewController:landmarkMapViewController animated:YES];
	[landmarkMapViewController release];
}

@end