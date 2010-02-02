//
//  GNAddLandmarkMapViewController.h
//  gnarus
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface GNAddLandmarkMapViewController : UIViewController {
	//MKMapView *_mapView;
	NSArray *_layers;
}

@property (nonatomic, retain) NSArray *layers;

//@property (nonatomic, retain) MKMapView *mapView;

- (void)addLandmark;

@end