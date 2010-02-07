//
//  GNPinAnnotationView.h
//  MapKitDragAndDrop
//
//  Created by iComps on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GNPinAnnotationView : MKPinAnnotationView {
	
@private
    BOOL				_isMoving;
    CGPoint				_startLocation;
    CGPoint				_originalCenter;
    UIImageView *		_pinShadow;
	
    MKMapView *			_mapView;
}

@property (nonatomic, assign) MKMapView *mapView;

@end