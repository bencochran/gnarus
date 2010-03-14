//
//  LayerListViewController.h
//  Displays all the active layers for a given landmark
//  If any of these layers is clicked, pushes the UIViewController
//    for the provided landmark on the indiated layer
//    onto the navigation stack
//
//  Created by Ben Cochran on 1/21/10.
//  Copyright 2010 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerManager/LayerManager.h>

@interface LayerListViewController : UITableViewController {
	// the landmark whose active layers are to be displayed
	GNLandmark *_landmark;
	// an array of active layers containing
	// information on the provided landmark
	NSArray *_layers;
}

@property (nonatomic, readonly) GNLandmark *landmark;
@property (nonatomic, readonly) NSArray *layers;

// initializes a LayersListViewController with the provided landmark
// and automatically creates the layers list by calling
// activeLayersForLandmark: on GNLayerManager
- (id)initWithLandmark:(GNLandmark *)landmark;

@end