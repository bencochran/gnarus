//
//  GNAddLandmarkLayersViewController.h
//  A UITableViewController that displays the layers to which the user can add
//    landmark information. If a layer is not user modifiable, that layer's
//    name is grey and not clickable. If a user clicks on a user modifiable
//    layer's name, the editing view controller for that layer is pushed
//    onto the navigation stack.
//
//  Created by iComps on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerManager/LayerManager.h>

@interface GNAddLandmarkLayersViewController : UITableViewController {
	// an array of all layers in GNLayerManager, possibly reordered
	// by the user - will display the layers' names in this order
	NSArray *_layers;
	// the user modifiable layer that the user clicked
	GNLayer *selectedLayer;
	// the location of the landmark to add, cannot be nil.
	// if the landmark already exists, this must be that
	// landmark's location
	CLLocation *selectedLocation;
	// the landmark whose layer information is to be edited
	// if adding an entirely new landmark, must be nil
	GNLandmark *selectedLandmark;
}

// must be set externally after initialization
@property (nonatomic, retain) NSArray *layers;

// initializes selectedLocation and selectedLandmark to the provided values
- (id)initWithLocation:(CLLocation *)location andLandmark:(GNLandmark *)landmark;

@end