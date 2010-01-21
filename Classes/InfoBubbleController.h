//
//  InfoBubbleController.h
//  gnarus
//
//  Created by Ben Cochran on 11/4/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerManager/LayerManager.h>
#import "InfoBubble.h"

extern NSString *const GNSelectedLandmark;

@interface InfoBubbleController : UIViewController <InfoBubbleDelegate> {
	GNLandmark *landmark;
}

@property (nonatomic, readonly) GNLandmark *landmark;

+ (id)bubbleControllerForLandmark:(GNLandmark *)aLandmark;
- (id)initWithLandmark:(GNLandmark *)aLandmark;

@end