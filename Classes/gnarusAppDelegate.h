//
//  gnarusAppDelegate.h
//  gnarus
//
//  Created by Ben Cochran on 10/27/09.
//  Copyright Ben Cochran 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface gnarusAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

