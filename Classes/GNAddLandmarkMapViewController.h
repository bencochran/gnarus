//
//  GNAddLandmarkMapViewController.h
//  A map view that allows the user to add/edit layer information for existing landmarks
//    and add entirely new landmarks. Shows all editable landmarks (validated and unvalidated)
//    within a radius of the user's location.
//  When user wants to edit layer information for a new or existing landmark, pushes a
//    GNAddLandmarkLayersViewController onto the navigation stack.
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <LayerManager/LayerManager.h>
#import "GNMutablePlacemark.h"

@interface GNAddLandmarkMapViewController : UIViewController <MKMapViewDelegate, MKReverseGeocoderDelegate> {
	MKMapView *_mapView;
	// the center around which all editable landmarks should be retrieved
	CLLocationCoordinate2D _userCoordinate;
	
	// an array of all layers in GNLayerManager, possibly reordered
	// by the user - will provide this ordering to GNAddLandmarkLayersViewController
	NSArray *_layers;
	// the dropped (purple) pin used when adding a new landmark
	GNMutablePlacemark *_addedAnnotation;
	
	// used to display the address range of the dropped pin
	MKReverseGeocoder *geocoder;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSArray *layers;	// must be set externally after initialization

// initializes the UIViewController with the given nib file name and nib bundle
// and sets _userCoordinate to the provided map center (and centers the map on the user)
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter;
// called when the plus button in the upper right hand corner of the screen is clicked
// deactivates this button and drops an editable purple pin in the center of the map
- (void)addAnnotation;
// when the user has pressed the blue arrow button in the callout of a pin,
// this method is called with that pin's GPS location and associated landmark
// if the landmark is new, landmark must be nil, but location cannot be nil
- (void)addLandmarkWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;

@end