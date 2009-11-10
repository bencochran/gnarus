//
//  LiveViewController.h
//  gnarus
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ARKit/ARKit.h>


@interface LiveViewController : UIViewController <ARViewDelegate> {
	ARGeoViewController *_arViewController;
}

@property (nonatomic, retain) ARGeoViewController *arViewController;

- (UIView *)viewForCoordinate:(ARCoordinate *)coordinate;

@end
