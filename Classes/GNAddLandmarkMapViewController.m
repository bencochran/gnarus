//
//  GNAddLandmarkMapViewController.m
//  gnarus
//
//  Created by iComps on 1/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNAddLandmarkMapViewController.h"
#import "GNAddLandmarkLayersViewController.h"


@implementation GNAddLandmarkMapViewController

@synthesize layers=_layers;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
		self.title = @"Landmarks";
    }
    return self;
}

- (void)viewDidLoad {
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self
								  action:@selector(addLandmark)];
	self.navigationItem.rightBarButtonItem = addButton;
	[addButton release];
}

- (void)addLandmark {
	NSLog(@"Adding landmark");
	GNAddLandmarkLayersViewController *landmarkLayersViewController = [[GNAddLandmarkLayersViewController alloc] initWithStyle:UITableViewStylePlain];
	landmarkLayersViewController.layers = self.layers;
	[self.navigationController pushViewController:landmarkLayersViewController animated:YES];
	[landmarkLayersViewController release];
		
	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[_layers release];
	
    [super dealloc];
}


@end
