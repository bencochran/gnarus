//
//  GNAddLandmarkMapViewController.m
//  gnarus
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNAddLandmarkMapViewController.h"
#import "GNAddLandmarkLayersViewController.h"
#import "GNPinAnnotationView.h"

@implementation GNAddLandmarkMapViewController

@synthesize mapView=_mapView;
@synthesize layers=_layers;
 
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"Landmarks";
		_addedAnnotation = nil;
		
#if TARGET_IPHONE_SIMULATOR
		// Make the simulator put us in an interesting location.
		mapCenter.latitude = 44.46087059486058;
		mapCenter.longitude = -93.1536018848419;
#endif
		
		_userCoordinate = mapCenter;
    }
    return self;
}

- (void)viewDidLoad {
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self
								  action:@selector(addAnnotation)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	// Set the center and dimensions of the map view
	MKCoordinateRegion region;
	region.center = _userCoordinate;
	region.span.latitudeDelta = 0.005;
	region.span.longitudeDelta = 0.005;
	[_mapView setRegion:region];
	_mapView.showsUserLocation = YES;
	
	// We want to know when the pin is moved
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(droppedPinChanged)
												 name:DDAnnotationCoordinateDidChangeNotification 
											   object:nil];

	// We want to know when new user-editable landmarks are available
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(landmarksUpdated:)
												 name:GNEditableLandmarksUpdated
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(ignorePinCallouts) 
												 name:dragStarted 
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(hearPinCallouts) 
												 name:dragIsDone 
											   object:nil];
}

-(void)ignorePinCallouts {
	for (NSObject<MKAnnotation> *annotation in self.mapView.annotations) {
		if (annotation != _addedAnnotation) {
			[[self.mapView viewForAnnotation:annotation] setEnabled:NO];
		}
	}
}

-(void)hearPinCallouts {
	for (NSObject<MKAnnotation> *annotation in self.mapView.annotations) {
		[[self.mapView viewForAnnotation:annotation] setEnabled:YES];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[[GNLayerManager sharedManager] updateEditableLandmarksForLocation:[[[CLLocation alloc] initWithLatitude:_userCoordinate.latitude longitude:_userCoordinate.longitude] autorelease]];
}

- (void)landmarksUpdated:(NSNotification *)note {
	NSArray *landmarks = [note.userInfo objectForKey:@"landmarks"];
	
	NSLog(@"Landmarks updated (in AddLandmarkMapView), number user-editable landmarks: %i", [landmarks count]);
	
	// We'll do the same for annotations, marking them for removal by default
	NSMutableArray *annotationsToRemove = [NSMutableArray arrayWithArray:self.mapView.annotations];
	
	// Never remove the userLocation annotation
	[annotationsToRemove removeObject:self.mapView.userLocation];
	// Never remove the added annotation (if it's not nil)
	if (_addedAnnotation) {
		[annotationsToRemove removeObject:_addedAnnotation];
	}
	
	for (GNLandmark *landmark in landmarks) {
		// Use the same logic for annotations that we use
		// for locations in the ARView
		if ([annotationsToRemove containsObject:landmark]) {
			[annotationsToRemove removeObject:landmark];
		} else {
			[self.mapView addAnnotation:landmark];
		}
	}
	
	// Finally, remove annotations that actually don't exist anymore
	[self.mapView removeAnnotations:annotationsToRemove];
}

- (void)droppedPinChanged {	
	if (geocoder) {
		geocoder.cancel;
		geocoder.delegate = nil;
		[geocoder release];
		geocoder = nil;
	}
	
	geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:_addedAnnotation.coordinate];
	geocoder.delegate = self;
	[geocoder start];	
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	_addedAnnotation.subtitle = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
	_addedAnnotation.subtitle = nil;
}

- (void)addAnnotation {
	NSLog(@"Adding annotation to: %f, %f", self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude);
	
	// Deactivate "+" button: don't allow more annotations to be added
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	// Create new annotation and add it to the mapView
	_addedAnnotation = [[GNMutablePlacemark alloc] initWithCoordinate:self.mapView.centerCoordinate addressDictionary:nil];
	_addedAnnotation.title = @"Drag To Move Pin";
	[_mapView addAnnotation:_addedAnnotation];
	[_mapView selectAnnotation:_addedAnnotation animated:YES];
	[self droppedPinChanged];
}

- (void)addLandmarkWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark{
	NSLog(@"Adding landmark with center: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
	NSLog(@"Adding landmark with existing landmark: %@", landmark);
	
	GNAddLandmarkLayersViewController *landmarkLayersViewController = [[GNAddLandmarkLayersViewController alloc] initWithLocation:location andLandmark:landmark];
	landmarkLayersViewController.layers = self.layers;
	[self.navigationController pushViewController:landmarkLayersViewController animated:YES];
	[landmarkLayersViewController release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	_mapView.delegate = nil;
    [_mapView release];
	
	geocoder.delegate = nil;
	[geocoder release];
	
	[_layers release];
	[_addedAnnotation release];	
	
	[super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	if (annotation == mapView.userLocation) {
		return nil;
	}
	MKPinAnnotationView *annotationView;
	
	if(annotation == _addedAnnotation) {
		annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"NewLandmark"];
		if (annotationView == nil) {
			NSLog(@"Adding New Annotation");
			annotationView = [[[GNPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"NewLandmark"] autorelease];
			annotationView.pinColor = MKPinAnnotationColorPurple;
			annotationView.animatesDrop = YES;
			annotationView.canShowCallout = YES;
			annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}
		// Dragging annotation will need _mapView to convert new point to coordinate
		((GNPinAnnotationView *) annotationView).mapView = mapView;
	}
	else {
		annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
		if (annotationView == nil) {
			annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title] autorelease];
			annotationView.pinColor = MKPinAnnotationColorRed;
			annotationView.animatesDrop = NO;
			annotationView.canShowCallout = YES;
			annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		}
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([control isKindOfClass:[UIButton class]]) {
		CLLocation *selectedLocation = [[CLLocation alloc] initWithLatitude:view.annotation.coordinate.latitude longitude:view.annotation.coordinate.longitude];
		GNLandmark *landmarkToAdd;
		if ([view.annotation isKindOfClass:[GNLandmark class]]) {
			landmarkToAdd = (GNLandmark *) view.annotation;
		} else {
			landmarkToAdd = nil;
		}
		[self addLandmarkWithLocation:selectedLocation andLandmark:landmarkToAdd];
		[selectedLocation release];
	}
}

@end