//
//  GNAddLandmarkLayersViewController.h
//  gnarus
//
//  Created by iComps on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerManager/LayerManager.h>

@interface GNAddLandmarkLayersViewController : UITableViewController {
	NSArray *_layers;
}

@property (nonatomic, retain) NSArray *layers;

@end
