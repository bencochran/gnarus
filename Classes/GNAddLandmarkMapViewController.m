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

@synthesize layers=_layers;
@synthesize mapView=_mapView;
@synthesize annotations=_annotations;
@synthesize addedAnnotation=_addedAnnotation;
 
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"Landmarks";
		
#if TARGET_IPHONE_SIMULATOR
		mapCenter.latitude = 44.456586120748355;
		mapCenter.longitude = -93.15977096557617;
#endif
		NSLog(@"center: %f, %f", mapCenter.latitude, mapCenter.longitude);
		userCoordinate = mapCenter;
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
	
	self.addedAnnotation = nil;
	selectedLocation = nil;
	
	NSLog(@"new center: %f, %f", userCoordinate.latitude, userCoordinate.longitude);
	MKCoordinateRegion region;
	region.center = userCoordinate;
	region.span.latitudeDelta = 0.005;
	region.span.longitudeDelta = 0.005;
	[self.mapView setRegion:region];
}

- (void)addAnnotation {
	self.navigationItem.rightBarButtonItem.enabled = NO;
	self.addedAnnotation = [[GNMutablePlacemark alloc] initWithCoordinate:self.mapView.centerCoordinate addressDictionary:nil];
	self.addedAnnotation.title = @"Drag to move pin";
	self.addedAnnotation.subtitle = @"Press arrow to edit information";
	[self.mapView addAnnotation:self.addedAnnotation];
}

- (void)addLandmarkWithLocation:(CLLocation *)location {
	NSLog(@"Adding landmark with center: %f, %f", location.coordinate.latitude, location.coordinate.longitude);
	GNAddLandmarkLayersViewController *landmarkLayersViewController = [[GNAddLandmarkLayersViewController alloc] initWithLocation:location];
	landmarkLayersViewController.layers = self.layers;
	[self.navigationController pushViewController:landmarkLayersViewController animated:YES];
	[landmarkLayersViewController release];
}

-(CLLocation *)getSelectedLocation {
	return selectedLocation;
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
	[self.annotations release];
	[self.addedAnnotation release];
	[selectedLocation release];
	
	[super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if (annotation == mapView.userLocation) {
		return nil;
	}
	
	GNPinAnnotationView *annotationView = (GNPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"NewLandmark"];
	if (annotationView == nil) {
		annotationView = [[[GNPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"NewLandmark"] autorelease];
		annotationView.pinColor = MKPinAnnotationColorRed;
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
	}
	// Dragging annotation will need _mapView to convert new point to coordinate
	annotationView.mapView = mapView;
	
	UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinFloating.png"]];
	annotationView.leftCalloutAccessoryView = leftIconView;
	[leftIconView release];
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	annotationView.rightCalloutAccessoryView = rightButton;		
	
	return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([control isKindOfClass:[UIButton class]]) {
		if (selectedLocation) {
			[selectedLocation release];
			selectedLocation = nil;
		}
		selectedLocation = [[CLLocation alloc] initWithLatitude:self.addedAnnotation.coordinate.latitude longitude:self.addedAnnotation.coordinate.longitude];
		[self addLandmarkWithLocation:selectedLocation];
	}
}

@end