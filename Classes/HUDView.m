//
//  HUDView.m
//  gnarus
//
//  Created by Ben Cochran on 2/23/10.
//
//  Inspired by http://github.com/jdg/MBProgressHUD
//	which has the following license:
//
//	Copyright (c) 2009 Matej Bukovinski
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "HUDView.h"

@interface HUDView ()

- (id)initWithWindow:(UIWindow *)window style:(HUDViewStyle)style;
- (id)initWithFrame:(CGRect)frame style:(HUDViewStyle)style;

- (void)show;
- (void)show:(BOOL)animated;
- (void)dismiss;
- (void)dismiss:(BOOL)animated;

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context;

@property (assign) HUDViewStyle style;
@property (assign) CGFloat height;
@property (assign) CGFloat width;
@property (copy) NSString *status;
@property (copy) NSString *statusDetails;

@end


@implementation HUDView

@synthesize style=_style;
@synthesize height=_height;
@synthesize width=_width;
@synthesize status=_status;
@synthesize statusDetails=_statusDetails;

- (void)setStyle:(HUDViewStyle)style {
	NSLog(@"setting style");
	if (_style != style) {
		_style = style;
		switch (_style) {
			case HUDViewStyleSpinner:
				NSLog(@"spinner");
				[_indicator removeFromSuperview];
				[_indicator release];
				_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
				[(UIActivityIndicatorView*)_indicator startAnimating];
				[self addSubview:_indicator];
				break;
			case HUDViewStyleError:
				NSLog(@"error");
				[_indicator removeFromSuperview];
				[_indicator release];
				_indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error-x.png"]];
				[self addSubview:_indicator];
				break;
			default:
				NSLog(@"neither");
				break;
		}
	}
}

#pragma mark -
#pragma mark Constants

#define MARGIN 20.0
#define PADDING 4.0

#define STATUSFONTSIZE 22.0
#define STATUSDETAILSFONTSIZE 16.0

#pragma mark -
#pragma mark Static Variables

static HUDView *hud = nil;
static NSTimer *timer = nil;

#pragma mark -
#pragma mark Static Methods

+ (void)showHUDStyle:(HUDViewStyle)style status:(NSString *)status statusDetails:(NSString *)statusDetails {
	BOOL animated = YES;
	if (hud != nil) {
		animated = NO;
		[timer invalidate];
		[hud dismiss:animated];
		[hud release];
	}
	hud = [[HUDView alloc] initWithWindow:[[UIApplication sharedApplication] keyWindow] style:style];
	if (status != nil) hud.status = status;
	if (statusDetails != nil) hud.statusDetails = statusDetails;
	[hud show:animated];	
}

+ (void)showHUDStyle:(HUDViewStyle)style status:(NSString *)status statusDetails:(NSString *)statusDetails forTime:(NSTimeInterval)time {
	[HUDView showHUDStyle:style status:status statusDetails:statusDetails];
	timer = [[NSTimer scheduledTimerWithTimeInterval:time target:[HUDView class] selector:@selector(dismiss) userInfo:nil repeats:NO] retain];
}

+ (void)dismiss {
	[hud dismiss];
	[hud release];
	hud = nil;
	
	[timer release];
	timer = nil;
}

#pragma mark -
#pragma mark Init/dealloc

- (id)initWithWindow:(UIWindow *)window style:(HUDViewStyle)style {
	return [self initWithFrame:[window bounds] style:style];
}

- (id)initWithFrame:(CGRect)frame style:(HUDViewStyle)style {
	if (self = [super initWithFrame:frame]) {
		// initialize the style to -1 so that anything is registered as a change
		_style = -1;
		self.style = style;
		
		self.status = nil;
		self.statusDetails = nil;
		
		self.alpha = 0.0;

		self.opaque = NO;
		self.backgroundColor = [UIColor clearColor];
		
		_statusLabel = [[UILabel alloc] initWithFrame:self.bounds];
		_statusDetailsLabel = [[UILabel alloc] initWithFrame:self.bounds];		
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame {
	return [self initWithFrame:frame style:HUDViewStyleSpinner];
}

- (void)dealloc {	
	[_statusLabel release];
	[_statusDetailsLabel release];
	[_status release];
	[_statusDetails release];
	[_indicator release];
	
	[super dealloc];
}

#pragma mark Control

- (void)show:(BOOL)animated {
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];

    // Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.40];
        self.alpha = 1.0;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 1.0;
    }
}

- (void)show {
	[self show:YES];
}

- (void)dismiss:(BOOL)animated {
	// Fade in
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.40];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationFinished:finished:context:)];
		self.alpha = 0.0;
        [UIView commitAnimations];
    }
    else {
        self.alpha = 0.0;
    }
}

- (void)dismiss {
	[self dismiss:YES];
}

- (void)animationFinished:(NSString *)animationID finished:(BOOL)finished context:(void*)context {
	[self removeFromSuperview];
}

//- (void)show:(BOOL)animated {
//	[self setNeedsDisplay];
//	[self showUsingAnimation:useAnimation];
//}

#pragma mark Layout

- (void)layoutSubviews {
	CGRect frame = self.bounds;

	CGRect indicatorFrame = _indicator.bounds;
	
	self.width = indicatorFrame.size.width + 2 * MARGIN;
	self.height = indicatorFrame.size.height + 2 * MARGIN;
	
	indicatorFrame.origin.x = floor((frame.size.width - indicatorFrame.size.width) / 2);
    indicatorFrame.origin.y = floor((frame.size.height - indicatorFrame.size.height) / 2);
    _indicator.frame = indicatorFrame;
	
	if (self.status != nil) {
		UIFont *statusFont = [UIFont boldSystemFontOfSize:STATUSFONTSIZE];
		CGSize statusSize = [self.status sizeWithFont:statusFont];

		CGSize labelSize = statusSize;
		if (statusSize.width > (frame.size.width - 2 * MARGIN)) {
			labelSize.width = frame.size.width - 4 * MARGIN;
		}
		
		// Set label properties
		_statusLabel.font = statusFont;
		_statusLabel.adjustsFontSizeToFitWidth = NO;
		_statusLabel.textAlignment = UITextAlignmentCenter;
		_statusLabel.opaque = NO;
		_statusLabel.backgroundColor = [UIColor clearColor];
		_statusLabel.textColor = [UIColor whiteColor];
		_statusLabel.text = self.status;
		
        // Update HUD size
		if (self.width < (labelSize.width + 2 * MARGIN)) {
            self.width = labelSize.width + 2 * MARGIN;
        }
		self.height = self.height + labelSize.height + PADDING;
		
		// Move indicator to make room for the label
		indicatorFrame.origin.y -= (floor(labelSize.height / 2 + PADDING / 2));
        _indicator.frame = indicatorFrame;

		// Set the label position and dimensions
        CGRect labelFrame = CGRectMake(floor((frame.size.width - labelSize.width) / 2),
                                   floor(indicatorFrame.origin.y + indicatorFrame.size.height + PADDING),
                                   labelSize.width, labelSize.height);
        _statusLabel.frame = labelFrame;
		
		[self addSubview:_statusLabel];

		if (nil != self.statusDetails) {
			statusFont = [UIFont boldSystemFontOfSize:STATUSDETAILSFONTSIZE];
			statusSize = [self.statusDetails sizeWithFont:statusFont];
			
			labelSize = statusSize;
			if (statusSize.width > (frame.size.width - 2 * MARGIN)) {
				labelSize.width = frame.size.width - 4 * MARGIN;
			}
			
			// Set label properties
			_statusDetailsLabel.font = statusFont;
			_statusDetailsLabel.adjustsFontSizeToFitWidth = NO;
			_statusDetailsLabel.textAlignment = UITextAlignmentCenter;
			_statusDetailsLabel.opaque = NO;
			_statusDetailsLabel.backgroundColor = [UIColor clearColor];
			_statusDetailsLabel.textColor = [UIColor whiteColor];
			_statusDetailsLabel.text = self.statusDetails;
			
			// Update HUD size
			if (self.width < (labelSize.width + 2 * MARGIN)) {
				self.width = labelSize.width + 2 * MARGIN;
			}
			self.height = self.height + labelSize.height + PADDING;
			
			// Move indicator to make room for the label
			indicatorFrame.origin.y -= (floor(labelSize.height / 2 + PADDING / 2));
			_indicator.frame = indicatorFrame;
			
			// Move first label to make room for the new label
            labelFrame.origin.y -= (floor(labelSize.height / 2 + PADDING / 2));
            _statusLabel.frame = labelFrame;			
			
			// Set the label position and dimensions
			labelFrame = CGRectMake(floor((frame.size.width - labelSize.width) / 2),
										   labelFrame.origin.y + labelFrame.size.height + PADDING,
										   labelSize.width, labelSize.height);
			_statusDetailsLabel.frame = labelFrame;
			
			[self addSubview:_statusDetailsLabel];
		}
	}
}

#pragma mark Interaction

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD bacgroud rect
    CGRect boxRect = CGRectMake(((allRect.size.width - self.width) / 2),
                                ((allRect.size.height - self.height) / 2), self.width, self.height);
	
	return CGRectContainsPoint(boxRect, point);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	touched = YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[HUDView dismiss];
	touched = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	touched = NO;
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    // Center HUD
    CGRect allRect = self.bounds;
    // Draw rounded HUD bacgroud rect
    CGRect boxRect = CGRectMake(((allRect.size.width - self.width) / 2),
                                ((allRect.size.height - self.height) / 2), self.width, self.height);
    CGContextRef ctxt = UIGraphicsGetCurrentContext();
    [self fillRoundedRect:boxRect inContext:ctxt];
}

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context {
    float radius = 10.0f;
	
    CGContextBeginPath(context);
    CGContextSetGrayFillColor(context, 0.0, 0.7);
    CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextFillPath(context);
}

@end