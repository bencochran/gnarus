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
}

@property (nonatomic, retain) NSArray *layers;
@property (nonatomic, retain) IBOutlet MKMapView *mapView;

- (void)addLandmark;

@end