//
//  InfoBubbleView.h
//  gnarus
//
//  Created by Ben Cochran on 11/3/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BubbleBackgroundView;
@protocol InfoBubbleDelegate;

@interface InfoBubble : UIView {
	BubbleBackgroundView *_bubble;
	UILabel *_label;
	
	CGRect _expandedBounds;
	CGRect _contractedBounds;
	BOOL expanded;
	
	NSObject<InfoBubbleDelegate> *_delegate;
}

@property (nonatomic, retain) BubbleBackgroundView *bubble;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic) CGRect expandedBounds;
@property (nonatomic) CGRect contractedBounds;
@property (nonatomic, assign) NSObject<InfoBubbleDelegate> *delegate;

+ (id)infoBubbleWithTitle:(NSString *)title;

- (void)expand;
- (void)contract;

@end

////////////////////////////////////////////////////////////

@interface BubbleBackgroundView : UIView {

}

@end

////////////////////////////////////////////////////////////

@protocol InfoBubbleDelegate

- (void)didSelectBubble:(InfoBubble *)bubble;

@end
