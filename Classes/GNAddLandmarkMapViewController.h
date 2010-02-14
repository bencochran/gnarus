//
//  GNAddLandmarkMapViewController.h
//  gnarus
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
	CLLocationCoordinate2D _userCoordinate;
	
	NSArray *_layers;
	
	NSMutableSet *_annotations;
	GNMutablePlacemark *_addedAnnotation;
	
	MKReverseGeocoder *geocoder;
}

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain) NSArray *layers;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter;
- (void)addAnnotation;
- (void)addLandmarkWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;

@end