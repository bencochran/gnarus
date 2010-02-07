//
//  GNAddLandmarkMapViewController.h
//  gnarus
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GNAddLandmarkMapViewController : UIViewController <MKMapViewDelegate> {
	MKMapView *_mapView;
	NSArray *_layers;
	CLLocation *selectedLocation;
	CLLocationCoordinate2D userCoordinate;
}

@property (nonatomic, retain) NSArray *layers;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil centerLocation:(CLLocationCoordinate2D)mapCenter;
- (void)addLandmark;

@end