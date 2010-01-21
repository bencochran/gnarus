//
//  InfoBubbleController.m
//  gnarus
//
//  Created by Ben Cochran on 11/4/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "InfoBubbleController.h"

@implementation InfoBubbleController

NSString *const GNSelectedLandmark = @"GNSelectedLandmark";

@synthesize landmark;

+ (id)bubbleControllerForLandmark:(GNLandmark *)aLandmark {
	return [[[InfoBubbleController alloc] initWithLandmark:aLandmark] autorelease];
}

- (id)initWithLandmark:(GNLandmark *)aLandmark {
	if (self = [super init]) {
		landmark = aLandmark;
	}
	
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	InfoBubble *bubble = [InfoBubble infoBubbleWithTitle:self.landmark.name];
	bubble.delegate = self;
	self.view = bubble;
}

- (void)didSelectBubble:(InfoBubble *)bubble {
	NSLog(@"Will post notification for landmark: %@", self.landmark);
	[[NSNotificationCenter defaultCenter] postNotificationName:GNSelectedLandmark
														object:self.landmark
													  userInfo:nil];	
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	NSLog(@"Lost bubble controller for landmark: %@", landmark);
	
	[landmark release];
	
	// Unhook us from being the delegate
	[(InfoBubble *)self.view setDelegate:nil];
	
    [super dealloc];
}


@end
