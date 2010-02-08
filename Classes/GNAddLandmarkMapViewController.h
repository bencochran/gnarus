//
//  GNAddLandmarkMapViewController.h
//  gnarus
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GNMutablePlacemark.h"

@interface GNAddLandmarkMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *_mapView;
	NSArray *_layers;
	NSMutableSet *_annotations;
	GNMutablePlacemark *_addedAnnotation;
	CLLocation *_selectedLocation;
	CLLocationCoordinate2D _userCoordinate;
}

@property (nonatomic, retain) NSArray *layers;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter;
- (void)addAnnotation;
- (void)addLandmarkWithLocation:(CLLocation *)location;

@end