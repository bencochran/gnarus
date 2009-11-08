//
//  InfoBubbleView.h
//  gnarus
//
//  Created by Ben Cochran on 11/3/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BubbleBackgroundView;

@interface InfoBubble : UIView {
	BubbleBackgroundView *_bubble;
	UILabel *_label;
	
	CGRect _expandedBounds;
	CGRect _contractedBounds;
	BOOL expanded;
}

@property (nonatomic, retain) BubbleBackgroundView *bubble;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic) CGRect expandedBounds;
@property (nonatomic) CGRect contractedBounds;


+ (id)infoBubbleWithTitle:(NSString *)title;

- (void)expand;
- (void)contract;

@end

////////////////////////////////////////////////////////////

@interface BubbleBackgroundView : UIView {

}

@end