//
//  GNMutablePlacemark.h
//  MapKitDragAndDrop
//
//  Created by iComps on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GNMutablePlacemark : MKPlacemark {

@private
	CLLocationCoordinate2D _coordinate;
	NSString *_title;
	NSString *_subtitle;
}

// Re-declare MKAnnotation's readonly property 'coordinate' to readwrite
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate addressDictionary:(NSDictionary *)newAddressDictionary;
@end