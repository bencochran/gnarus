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
#import <LayerManager/LayerManager.h>

@implementation GNAddLandmarkMapViewController

@synthesize layers=_layers;
@synthesize mapView=_mapView;
 
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"Landmarks";
		
#if TARGET_IPHONE_SIMULATOR
		mapCenter.latitude = 44.456586120748355;
		mapCenter.longitude = -93.15977096557617;
#endif
		NSLog(@"Center: %f, %f", mapCenter.latitude, mapCenter.longitude);
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
	
	_addedAnnotation = nil;
	_selectedLocation = nil;
	
	NSLog(@"New center: %f, %f", _userCoordinate.latitude, _userCoordinate.longitude);
	MKCoordinateRegion region;
	region.center = _userCoordinate;
	region.span.latitudeDelta = 0.005;
	region.span.longitudeDelta = 0.005;
	[_mapView setRegion:region];
	
	// Add annotations for the closest landmarks
	_annotations = [[NSMutableSet alloc] init];
	GNMutablePlacemark *landmarkPlacemark;
	for (GNLandmark *landmark in [[GNLayerManager sharedManager] closestLandmarks]) {
		landmarkPlacemark = [[GNMutablePlacemark alloc] initWithCoordinate:landmark.coordinate addressDictionary:nil];
		landmarkPlacemark.title = landmark.name;
		landmarkPlacemark.subtitle = nil;
		[_annotations addObject:landmarkPlacemark];
		[_mapView addAnnotation:landmarkPlacemark];
		[landmarkPlacemark release];
	}
}

- (void)addAnnotation {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	_addedAnnotation = [[GNMutablePlacemark alloc] initWithCoordinate:self.mapView.centerCoordinate addressDictionary:nil];
	_addedAnnotation.title = @"Drag to move pin";
	_addedAnnotation.subtitle = @"Press arrow to edit information";
	[_mapView addAnnotation:_addedAnnotation];
}

- (void)addLandmarkWithLocation:(CLLocation *)location {
	NSLog(@"Adding landmark with center: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
	GNAddLandmarkLayersViewController *landmarkLayersViewController = [[GNAddLandmarkLayersViewController alloc] initWithLocation:location];
	landmarkLayersViewController.layers = _layers;
	[self.navigationController pushViewController:landmarkLayersViewController animated:YES];
	[landmarkLayersViewController release];
}

-(CLLocation *)getSelectedLocation {
	return _selectedLocation;
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
	
	[_layers release];
	[_annotations release];
	[_addedAnnotation release];
	[_selectedLocation release];
	
	[super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if (annotation == mapView.userLocation) {
		return nil;
	}
	
	MKPinAnnotationView *annotationView;
	
	if(annotation == _addedAnnotation) {
		annotationView = (GNPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"NewLandmark"];
		if (annotationView == nil) {
			annotationView = [[[GNPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"NewLandmark"] autorelease];
			annotationView.pinColor = MKPinAnnotationColorPurple;
			annotationView.animatesDrop = YES;
			annotationView.canShowCallout = YES;
		}
		// Dragging annotation will need _mapView to convert new point to coordinate
		((GNPinAnnotationView *) annotationView).mapView = mapView;
		
		UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinFloatingPurple.png"]];
		annotationView.leftCalloutAccessoryView = leftIconView;
		[leftIconView release];
		
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		annotationView.rightCalloutAccessoryView = rightButton;	
	}
	else {
		annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotation.title];
		if (annotationView == nil) {
			annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotation.title] autorelease];
			annotationView.pinColor = MKPinAnnotationColorRed;
			annotationView.animatesDrop = NO;
			annotationView.canShowCallout = YES;
		}
	}
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([control isKindOfClass:[UIButton class]]) {
		if (_selectedLocation) {
			[_selectedLocation release];
			_selectedLocation = nil;
		}
		_selectedLocation = [[CLLocation alloc] initWithLatitude:_addedAnnotation.coordinate.latitude longitude:_addedAnnotation.coordinate.longitude];
		[self addLandmarkWithLocation:_selectedLocation];
	}
}

@end