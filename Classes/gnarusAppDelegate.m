//
//  gnarusAppDelegate.m
//  gnarus
//
//  Created by Ben Cochran on 10/27/09.
//  Copyright Ben Cochran 2009. All rights reserved.
//

#import "gnarusAppDelegate.h"
#import "LiveViewController.h"

@implementation gnarusAppDelegate

@synthesize window, navController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	[application setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
	
	LiveViewController *viewController = [[LiveViewController alloc] initWithCoder:nil];
	
	self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[viewController release];
	
    [window addSubview:navController.view];
	[window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
