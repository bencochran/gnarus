//
//  LayerListViewController.m
//  gnarus
//
//  Created by Ben Cochran on 1/21/10.
//  Copyright 2010 Ben Cochran. All rights reserved.
//

#import "LayerListViewController.h"

@implementation LayerListViewController

@synthesize landmark=_landmark, layers=_layers;

- (id)initWithLandmark:(GNLandmark *)landmark {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		_landmark = landmark;
		_layers = [[[GNLayerManager sharedManager] activeLayersForLandmark:landmark] retain];
		self.title = landmark.name;
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.layers count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [[self.layers objectAtIndex:indexPath.row] name];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController *viewController = [(GNLayer *)[self.layers objectAtIndex:indexPath.row] viewControllerForLandmark:self.landmark];
	[self.navigationController pushViewController:viewController animated:YES];

    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}

- (void)dealloc {
	[_landmark release];
	[_layers release];
    [super dealloc];
}

@end