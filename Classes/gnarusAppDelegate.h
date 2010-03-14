//
//  gnarusAppDelegate.h
//  Sets up the window and navigation controller,
//    and adds the LiveViewController to the navigation stack
//
//  Created by Ben Cochran on 10/27/09.
//  Copyright Ben Cochran 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gnarusAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navController;

@end