//
//  LayerListViewController.h
//  gnarus
//
//  Created by Ben Cochran on 1/21/10.
//  Copyright 2010 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerManager/LayerManager.h>

@interface LayerListViewController : UITableViewController {
	GNLandmark *_landmark;
}

@property (nonatomic, readonly) GNLandmark *landmark;

- (id)initWithLandmark:(GNLandmark *)landmark;

@end
