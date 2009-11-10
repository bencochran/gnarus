//
//  InfoBubble.m
//  gnarus
//
//  Created by Ben Cochran on 11/3/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "InfoBubble.h"


@implementation InfoBubble

@synthesize bubble=_bubble, label=_label, expandedBounds=_expandedBounds,
			contractedBounds=_contractedBounds;

+ (id)infoBubbleWithTitle:(NSString *)title {
	return [[[InfoBubble alloc] initWithTitle:title] autorelease];
}

- (id)initWithTitle:(NSString *)title {
	if (self = [super init]) {
		self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.8;
		self.contentMode = UIViewContentModeRedraw;
		self.clipsToBounds = NO;
		//self.autoresizesSubviews = YES;
		
		// Use the size of the text to determine the width of this info bubble
		UIFont *font = [UIFont boldSystemFontOfSize:14];
		CGSize labelSize = [title sizeWithFont:font constrainedToSize:CGSizeMake(150, 0) lineBreakMode:UILineBreakModeTailTruncation];

		self.contractedBounds = CGRectMake(0, 0, labelSize.width + 35, 79);
		self.expandedBounds = CGRectMake(-25, 0, labelSize.width + 85, 79);
		
		self.bounds = self.contractedBounds;
		expanded = NO;
		
		// make the bubble background
		CGRect bubbleFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height);
		self.bubble = [[[BubbleBackgroundView alloc] initWithFrame:bubbleFrame] autorelease];
		[self addSubview:self.bubble];
		
		// make the label
		//CGRect labelFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width - labelSize.width - 5, self.bounds.origin.y+7, labelSize.width, labelSize.height);
		CGRect labelFrame = CGRectMake(30, 7, labelSize.width, labelSize.height);
		self.label = [[UILabel alloc] initWithFrame:labelFrame];
//		CGPoint center = self.label.center;
//		center.x = (self.bounds.size.width / 2.0) + 12.5; // 10 (for 
//		self.label.center = center;

		self.label.backgroundColor = [UIColor clearColor];
		self.label.text = title;
		self.label.textColor = [UIColor whiteColor];
		self.label.shadowColor = [UIColor blackColor];
		self.label.shadowOffset = CGSizeMake(0, -1);
		self.label.lineBreakMode = UILineBreakModeTailTruncation;
		self.label.font = font;		
		[self addSubview:self.label];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing code ... nothing
}

- (void)expand {
	[UIView beginAnimations:@"expand" context:nil];
	[UIView setAnimationDuration:0.3];
	
	self.bounds = self.expandedBounds;
	self.bubble.frame = self.expandedBounds;
	expanded = YES;
	[UIView commitAnimations];

}

- (void)contract {
	[UIView beginAnimations:@"contract" context:nil];
	[UIView setAnimationDuration:0.3];

	self.bounds = self.contractedBounds;
	self.bubble.frame = self.contractedBounds;
	expanded = NO;
	[UIView commitAnimations];
}

- (void)layoutSubviews {
//	CGPoint center = self.label.center;
//	center.x = (self.bounds.size.width / 2.0) + 12.5; // 10 (for 
//	self.label.center = center;
	
//	CGRect bubbleFrame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.frame.size.width, self.frame.size.height);
//	self.bubble.frame = bubbleFrame;
//	
//	CGRect labelFrame = CGRectMake(self.bounds.origin.x + self.bounds.size.width - self.label.frame.size.width - 5, self.bounds.origin.y+7, self.label.frame.size.width, self.label.frame.size.height);
//	self.label.frame = labelFrame;
//	[super layoutSubviews];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	NSLog(@"touch ended: %@", touch);
	if (expanded) {
		[self contract];
	} else {
		[self expand];
	}

}

- (void)dealloc {
	[_label release];
	[_bubble release];
    [super dealloc];
}


@end

////////////////////////////////////////////////////////////

@implementation BubbleBackgroundView

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.contentMode = UIViewContentModeRedraw;
//		self.contentStretch = CGRectMake(0.1, 0, 0.8, 0.5);
//		self.contentStretch = CGRectMake(0.5, 0.5, 0.0, 0.0);
//		self.contentStretch = CGRectMake(0, 0, 0.25, 0.25);
		self.clipsToBounds = NO;
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	NSLog(@"bubble setFrame: %@",NSStringFromCGRect(frame));
	[super setFrame:frame];
}

- (void)drawRect:(CGRect)rect {
	NSLog(@"bubble frame: %@", NSStringFromCGRect(self.frame));
	NSLog(@"bubble bounds: %@", NSStringFromCGRect(self.bounds));
	CGPoint origin = self.bounds.origin;
	CGSize size = self.bounds.size;
	
//	CGRect imageBounds = CGRectMake(0.0, 0.0, kBubbleViewWidth, kBubbleViewHeight);
//	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *color;
	//CGFloat alignStroke;
	CGFloat stroke;
	CGMutablePathRef path;
	CGPathRef strokePath;
	CGPoint point;
	CGPoint controlPoint1;
	CGPoint controlPoint2;
	CGGradientRef gradient;
	NSMutableArray *colors;
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGAffineTransform transform;
	CGMutablePathRef tempPath;
	CGRect pathBounds;
	CGPoint point2;
	CGFloat locations[2];
	
	CGContextSaveGState(context);
	//CGContextTranslateCTM(context, self.bounds.origin.x, self.bounds.origin.y);
	//CGContextScaleCTM(context, (bounds.size.width / imageBounds.size.width), (bounds.size.height / imageBounds.size.height));
	
	// Setup for shadow
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.36];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(4.0 * cos(-1.571), 4.0 * sin(-1.571)), 5.0, [color CGColor]);
	CGContextBeginTransparencyLayer(context, NULL);
	
	// main bubble
	
	stroke = 1.0;
	if (stroke < 1.0)
		stroke = ceil(stroke);
	else
		stroke = round(stroke);
	stroke *= 2.0;
	//alignStroke = fmod(0.5 * stroke, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(origin.x, origin.y+4);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x+4, origin.y);
	controlPoint1 = CGPointMake(origin.x, origin.y+1.791);
	controlPoint2 = CGPointMake(origin.x+1.791, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y);
	controlPoint1 = CGPointMake(origin.x+4, origin.y);
	controlPoint2 = CGPointMake(origin.x + size.width - 4, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y+4);
	controlPoint1 = CGPointMake(origin.x + size.width - 1.791, origin.y);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y+1.791);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y+28);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y+4);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y+28);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y+32);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 30.209);
	controlPoint2 = CGPointMake(origin.x + size.width - 1.791, origin.y + 32);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0) + 9, origin.y + 32);
	controlPoint1 = CGPointMake(origin.x + size.width - 4, origin.y + 32);
	controlPoint2 = CGPointMake(origin.y + (size.width / 2.0) + 9, origin.y + 32);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0), origin.y + 41);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0) -9, origin.y + 32);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + 4, origin.y + 32);
	controlPoint1 = CGPointMake(origin.x + (size.width / 2.0) - 9, origin.y + 32);
	controlPoint2 = CGPointMake(origin.x + 4, origin.y+ 32);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 28);
	controlPoint1 = CGPointMake(origin.x + 1.791, origin.y + 32);
	controlPoint2 = CGPointMake(origin.x, origin.y + 30.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 4);
	controlPoint1 = CGPointMake(origin.x, origin.y + 28);
	controlPoint2 = CGPointMake(origin.x, origin.y + 4);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGPathCloseSubpath(path);
	colors = [NSMutableArray arrayWithCapacity:2];
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[0] = 0.0;
	color = [UIColor colorWithRed:0.296 green:0.296 blue:0.296 alpha:1.0];
	[colors addObject:(id)[color CGColor]];
	locations[1] = 1.0;
	gradient = CGGradientCreateWithColors(space, (CFArrayRef)colors, locations);
	CGContextAddPath(context, path);
	CGContextSaveGState(context);
	CGContextEOClip(context);
	transform = CGAffineTransformMakeRotation(1.571);
	tempPath = CGPathCreateMutable();
	CGPathAddPath(tempPath, &transform, path);
	pathBounds = CGPathGetBoundingBox(tempPath);
	point = pathBounds.origin;
	point2 = CGPointMake(CGRectGetMaxX(pathBounds), CGRectGetMinY(pathBounds));
	transform = CGAffineTransformInvert(transform);
	point = CGPointApplyAffineTransform(point, transform);
	point2 = CGPointApplyAffineTransform(point2, transform);
	CGPathRelease(tempPath);
	CGContextDrawLinearGradient(context, gradient, point, point2, (kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation));
	CGContextRestoreGState(context);
	strokePath = CGPathCreateCopy(path);
//	CGGradientRelease(gradient);
//	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
//	[color setStroke];
//	CGContextSetLineWidth(context, stroke);
//	CGContextSetLineCap(context, kCGLineCapSquare);
//	CGContextSaveGState(context);
//	CGContextAddPath(context, path);
//	//CGContextAddRect(context, imageBounds);
//	CGContextEOClip(context);
//	CGContextAddPath(context, path);
//	CGContextStrokePath(context);
//	CGContextRestoreGState(context);
//	strokePath = path;
	CGPathRelease(path);
	
	// shadow
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	// glass
	
	//alignStroke = 0.0;
	path = CGPathCreateMutable();
	point = CGPointMake(origin.x, origin.y + 4);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + 4, origin.y);
	controlPoint1 = CGPointMake(origin.x, origin.y + 1.791);
	controlPoint2 = CGPointMake(origin.x + 1.791, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y);
	controlPoint1 = CGPointMake(origin.x + 4, origin.y);
	controlPoint2 = CGPointMake(origin.x + size.width + 4, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y + 4);
	controlPoint1 = CGPointMake(origin.x + size.width - 1.719, origin.y);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y + 1.791);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.x + 13);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 4);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y + 13);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y + 17);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 15.209);
	controlPoint2 = CGPointMake(origin.x + size.width - 1.791, origin.y + 17);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + 4, origin.y + 17);
	controlPoint1 = CGPointMake(origin.x + size.width - 4, origin.y + 17);
	controlPoint2 = CGPointMake(origin.x + 4, origin.y + 17);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 13);
	controlPoint1 = CGPointMake(origin.x + 1.791, origin.y + 17);
	controlPoint2 = CGPointMake(origin.x, origin.y + 15.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 4);
	controlPoint1 = CGPointMake(origin.x, origin.y + 13);
	controlPoint2 = CGPointMake(origin.x, origin.y + 4);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGPathCloseSubpath(path);
	color = [UIColor colorWithRed:0.645 green:0.645 blue:0.645 alpha:0.35];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// emboss top
	
	//alignStroke = 0.0;
	path = CGPathCreateMutable();
	point = CGPointMake(origin.x, origin.y + 4);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + 4, origin.y);
	controlPoint1 = CGPointMake(origin.x, origin.y + 1.791);
	controlPoint2 = CGPointMake(origin.x + 1.791, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y);
	controlPoint1 = CGPointMake(origin.x + 4, origin.y);
	controlPoint2 = CGPointMake(origin.x + size.width - 4, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y + 4);
	controlPoint1 = CGPointMake(origin.x + size.width - 1.791, origin.y);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y + 1.791);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y + 6);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 4);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y + 6);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y + 2);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 3.791);
	controlPoint2 = CGPointMake(origin.x + size.width - 1.791, origin.y);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + 4, origin.y + 2);
	controlPoint1 = CGPointMake(origin.x + size.width - 4, origin.y + 2);
	controlPoint2 = CGPointMake(origin.x + 4, origin.y + 2);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 6);
	controlPoint1 = CGPointMake(origin.x + 1.791, origin.y + 2);
	controlPoint2 = CGPointMake(origin.x, origin.y + 3.791);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 4);
	controlPoint1 = CGPointMake(origin.x, origin.y + 6);
	controlPoint2 = CGPointMake(origin.x, origin.y + 4);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGPathCloseSubpath(path);
	color = [UIColor colorWithRed:1 green:1.0 blue:1 alpha:0.4];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// emboss bottom
	
	//alignStroke = 0.0;
	path = CGPathCreateMutable();
	point = CGPointMake(origin.x, origin.y + 26);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + 4.125, origin.y + 30);
	controlPoint1 = CGPointMake(origin.x, origin.y + 28.209);
	controlPoint2 = CGPointMake(origin.x + 1.916, origin.y + 30);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0) - 9, origin.y + 30);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0), origin.y + 39);
	controlPoint1 = CGPointMake(origin.x + (size.width / 2.0) - 9, origin.y + 30);
	controlPoint2 = CGPointMake(origin.x + (size.width / 2.0), origin.y + 39);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0) + 9, origin.y + 30);
	controlPoint1 = CGPointMake(origin.x + (size.width / 2.0), origin.y + 39);
	controlPoint2 = CGPointMake(origin.x + (size.width / 2.0) + 9, origin.y + 30);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y + 30);
	controlPoint1 = CGPointMake(origin.x + (size.width / 2.0) + 9, origin.y + 30);
	controlPoint2 = CGPointMake(origin.x + size.width - 4, origin.y + 30);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y + 26); // + 0.125 on x
	controlPoint1 = CGPointMake(origin.x + size.width - 1.791, origin.y + 30);
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y + 28.209); // + 0.125 on x
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width, origin.y + 28);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 26); // + 0.125 on x
	controlPoint2 = CGPointMake(origin.x + size.width, origin.y + 28);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + size.width - 4, origin.y + 32);
	controlPoint1 = CGPointMake(origin.x + size.width, origin.y + 30.209);
	controlPoint2 = CGPointMake(origin.x + size.width - 1.291, origin.y + 32);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0) + 9, origin.y + 32);
	controlPoint1 = CGPointMake(origin.x + size.width - 4, origin.y + 32);
	controlPoint2 = CGPointMake(origin.x + (size.width / 2.0) + 9, origin.y + 32);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0), origin.y + 41);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + (size.width / 2.0) - 9, origin.y + 32);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(origin.x + 4, origin.y + 32);
	controlPoint1 = CGPointMake(origin.x + (size.width) - 9, origin.y + 32);
	controlPoint2 = CGPointMake(origin.x + 4, origin.y + 32);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 28);
	controlPoint1 = CGPointMake(origin.x + 1.791, origin.y + 32);
	controlPoint2 = CGPointMake(origin.x, origin.y + 30.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(origin.x, origin.y + 26);
	controlPoint1 = CGPointMake(origin.x, origin.y + 28);
	controlPoint2 = CGPointMake(origin.x, origin.y + 26);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGPathCloseSubpath(path);
	color = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.14];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	CGGradientRelease(gradient);
	color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	[color setStroke];
	CGContextSetLineWidth(context, 2.0);
	CGContextSetLineCap(context, kCGLineCapSquare);
	CGContextSaveGState(context);
	CGContextAddPath(context, strokePath);
	//CGContextAddRect(context, imageBounds);
	CGContextEOClip(context);
	CGContextAddPath(context, strokePath);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	//strokePath = path;
	CGPathRelease(strokePath);
	
	
	NSLog(@"Unregistered Copy of Opacity");
	
	CGContextRestoreGState(context);
	CGColorSpaceRelease(space);
}

@end

