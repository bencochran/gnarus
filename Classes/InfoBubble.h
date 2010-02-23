//
//  InfoBubbleView.h
//  gnarus
//
//  Created by Ben Cochran on 11/3/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LayerManager/LayerManager.h>

@class BubbleBackgroundView;

extern NSString *const GNSelectedLandmark;

@interface InfoBubble : UIView {
	BubbleBackgroundView *_bubble;
	UILabel *_label;
	GNLandmark *_landmark;
	
	CGRect _expandedBounds;
	CGRect _contractedBounds;
	BOOL expanded;
}

@property (nonatomic, retain) BubbleBackgroundView *bubble;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) GNLandmark *landmark;
@property (nonatomic) CGRect expandedBounds;
@property (nonatomic) CGRect contractedBounds;

+ (id)infoBubbleWithLandmark:(GNLandmark *)landmark;

- (id)initWithLandmark:(GNLandmark *)landmark;
- (void)expand;
- (void)contract;

@end

////////////////////////////////////////////////////////////

@interface BubbleBackgroundView : UIView {

}

@end
