//
//  GNAddLandmarkMapViewController.m
//  gnarus
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNAddLandmarkMapViewController.h"
#import "GNAddLandmarkLayersViewController.h"


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
		NSLog(@"center: %f, %f", mapCenter.latitude, mapCenter.longitude);
		userCoordinate = mapCenter;
    }
    return self;
}

- (void)viewDidLoad {
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self
								  action:@selector(addLandmark)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
	
	NSLog(@"new center: %f, %f", userCoordinate.latitude, userCoordinate.longitude);
	MKCoordinateRegion region;
	region.center = userCoordinate;
	region.span.latitudeDelta = 0.005;
	region.span.longitudeDelta = 0.005;
	[self.mapView setRegion:region];
}

- (void)addLandmark {
	NSLog(@"Adding landmark");
	GNAddLandmarkLayersViewController *landmarkLayersViewController = [[GNAddLandmarkLayersViewController alloc] initWithStyle:UITableViewStylePlain];
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
	[_layers release];
	
	_mapView.delegate = nil;
    [_mapView release];
	_mapView = nil;
	
	[super dealloc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
	
	/*if (annotation == mapView.userLocation) {
		return nil;
	}
	
	GNPinAnnotationView *annotationView = (GNPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin"];
	if (annotationView == nil) {
		annotationView = [[[GNPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"] autorelease];
		annotationView.pinColor = MKPinAnnotationColorRed;
		annotationView.animatesDrop = YES;
		annotationView.canShowCallout = YES;
	}
	// Dragging annotation will need _mapView to convert new point to coordinate
	annotationView.mapView = mapView;
	
	UIImageView *leftIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinFloating.png"]];//@"digdog.png"]];
	annotationView.leftCalloutAccessoryView = leftIconView;
	[leftIconView release];
	
	UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	annotationView.rightCalloutAccessoryView = rightButton;		
	
	return annotationView;*/
	return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	/*if ([control isKindOfClass:[UIButton class]]) {		
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
	}*/
}

@end
