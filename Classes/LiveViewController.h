//
//  LiveViewController.h
//  The primary control of the Gnarus application.
//  Displays the camera feed, populates the layers in GNLayerManager, passes new landmark information
//    from GNLayerManager to ARKit for drawing, handles click events of landmark bubbles by pushing
//    landmarks' UIViewControllers onto the navigation stack (or pushes a LayersListViewController if
//    a landmark has more than one active layer), communicates with the GNToggleBar for reordering layers
//    and turning them on and off, and displays a map view when the phone is held flat.
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>
#import <GnarusToggleBar/GnarusToggleBar.h>
#import <LayerManager/LayerManager.h>
#import <MapKit/MapKit.h>
#import "GNAddLandmarkMapViewController.h"
#import "HUDView.h"

@interface LiveViewController : UIViewController <ARViewDelegate, CLLocationManagerDelegate, GNToggleBarDelegate, MKMapViewDelegate> {
	ARGeoViewController *_arViewController;
	
	MKMapView *_mapView;
	
	CLLocationManager *_locationManager;
	CLLocation *lastUsedLocation;
	
	BOOL pointingDown;
	
	GNToggleBarController *_toggleBarController;
	// maps each item in the toggle bar to the GNLayer with which
	// that item is associated
	NSMutableDictionary *_itemsToLayers;
	
	int connectionCount;
}

@property (nonatomic, retain) ARGeoViewController *arViewController;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) GNToggleBarController *toggleBarController;
@property (nonatomic, retain) NSMutableDictionary *itemsToLayers;
@property (nonatomic, readonly) NSArray *userOrderedLayers;

@end