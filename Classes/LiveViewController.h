//
//  LiveViewController.h
//  gnarus
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>

@class LiveViewGlassController;

@interface LiveViewController : UIViewController <ARViewDelegate, CLLocationManagerDelegate> {
	ARGeoViewController *_arViewController;
	
	CLLocationManager *_locationManager;
	
	LiveViewGlassController *_glassController;
}

@property (nonatomic, retain) ARGeoViewController *arViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) LiveViewGlassController *glassController;


- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;

@end

////////////////////////////////////////////////////////////

@interface LiveViewGlassController : UIViewController {
	
}

@end
