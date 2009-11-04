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
}

@property (nonatomic, retain) BubbleBackgroundView *bubble;

+ (id)infoBubbleWithTitle:(NSString *)title;

@end

////////////////////////////////////////////////////////////

@interface BubbleBackgroundView : UIView {

}

@end