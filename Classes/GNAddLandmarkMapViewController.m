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
		//mapCenter.latitude = 43;
		//mapCenter.longitude = -92;
#endif
		NSLog(@"Map center: %f, %f", mapCenter.latitude, mapCenter.longitude);
		
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
	
	NSLog(@"User location: %f, %f", _userCoordinate.latitude, _userCoordinate.longitude);
	
	// We want to know when the pin is moved
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(droppedPinChanged)
												 name:DDAnnotationCoordinateDidChangeNotification 
											   object:nil];		
	
	// Add annotations for the closest landmarks
	_annotations = [[NSMutableSet alloc] init];
	GNMutablePlacemark *landmarkPlacemark;
	for (GNLandmark *landmark in [[GNLayerManager sharedManager] closestLandmarks]) {
		landmarkPlacemark = [[GNMutablePlacemark alloc] initWithLandmark:landmark addressDictionary:nil];
		landmarkPlacemark.title = landmark.name;
		NSString *subtitleString = [[landmark.activeLayers objectAtIndex:0] name];
		for (int i = 1; i < [landmark.activeLayers count]; i++) {
			subtitleString = [subtitleString stringByAppendingString:@", "];
			subtitleString = [subtitleString stringByAppendingString:[[landmark.activeLayers objectAtIndex:i] name]];
		}
		landmarkPlacemark.subtitle = subtitleString;
		[_annotations addObject:landmarkPlacemark];
		[_mapView addAnnotation:landmarkPlacemark];
		[landmarkPlacemark release];
	}
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
	
	// Deactivate "+" button - don't allow more annotations to be added
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
	landmarkLayersViewController.layers = _layers;
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
	[_annotations release];
	[_addedAnnotation release];
	
	[super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if (annotation == mapView.userLocation) {
		return nil;
	}
	GNPinAnnotationView *annotationView;
	
	if(annotation == _addedAnnotation) {
		annotationView = (GNPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"NewLandmark"];
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
		annotationView = (GNPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
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
		[self addLandmarkWithLocation:selectedLocation andLandmark:((GNMutablePlacemark *) (view.annotation)).landmark];
		[selectedLocation release];
	}
}

@end