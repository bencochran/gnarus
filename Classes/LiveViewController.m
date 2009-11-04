//
//  LiveViewController.m
//  gnarus
//
//  Created by Ben Cochran on 11/2/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "LiveViewController.h"
#import <GnarusToggleBar/GnarusToggleBar.h>
#import "InfoBubbleController.h"

@implementation LiveViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		self.wantsFullScreenLayout = YES;
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	self.view = [[[UIView alloc] init] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	// Add image
	UIImageView *imageView = [[[UIImageView alloc] initWithFrame:self.view.frame] autorelease];
	imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	imageView.image = [UIImage imageNamed:@"bg.jpg"];
	[self.view addSubview:imageView];
	
	// Add an info bubble
	InfoBubbleController *infoBubbleController = [[[InfoBubbleController alloc] init] autorelease];
	infoBubbleController.title = @"Memorial Hall";
	infoBubbleController.view.center = self.view.center;
	[self.view addSubview:infoBubbleController.view];
	
	// Add toggle bar
	GNToggleBarController *toggleBarController = [[[GNToggleBarController alloc] init] autorelease];
	[self.view addSubview:toggleBarController.view];
	CGRect barFrame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + self.view.frame.size.height - 58, self.view.frame.size.width, 58);
	toggleBarController.view.frame = barFrame;

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:YES animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.navigationController setNavigationBarHidden:NO animated:animated];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];
}

- (void)buttonClick:(id)sender {

	UIViewController *viewController = [[UIViewController alloc] init];
	viewController.title = @"Hello";

	UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 95, 21)] autorelease];
	label.text = @"Hello, world";
	label.center = viewController.view.center;
	label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	[viewController.view addSubview:label];

	[self.navigationController pushViewController:viewController animated:YES];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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


- (void)dealloc {
    [super dealloc];
}


@end
