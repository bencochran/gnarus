//
//  GNMutablePlacemark.m
//  MapKitDragAndDrop
//
//  Created by iComps on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNMutablePlacemark.h"

#pragma mark -
#pragma mark GNMutablePlacemark implementation

@implementation GNMutablePlacemark

@synthesize coordinate = _coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

#pragma mark -
#pragma mark MKPlacemark Boilerplate

- (id)initWithCoordinate:(CLLocationCoordinate2D)newCoordinate addressDictionary:(NSDictionary *)newAddressDictionary {
	
	if ((self = [super initWithCoordinate:newCoordinate addressDictionary:newAddressDictionary])) {
		_coordinate = newCoordinate;		
	}
	return self;
}

- (void)dealloc {
	[_title release];
	[_subtitle release];
	[super dealloc];
}

@end