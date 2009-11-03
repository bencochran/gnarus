//
//  gnarusAppDelegate.m
//  gnarus
//
//  Created by Ben Cochran on 10/27/09.
//  Copyright Ben Cochran 2009. All rights reserved.
//

#import "gnarusAppDelegate.h"

@implementation gnarusAppDelegate

@synthesize window;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	
	// Chris didn't write this line, but oh well
	
    // Override point for customization after application launch
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
