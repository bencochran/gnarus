//
//  InfoBubble.m
//  gnarus
//
//  Created by Ben Cochran on 11/3/09.
//  Copyright 2009 Ben Cochran. All rights reserved.
//

#import "InfoBubble.h"


@implementation InfoBubble

@synthesize bubble=_bubble;

+ (id)infoBubbleWithTitle:(NSString *)title {
	InfoBubble *bubble = [[[InfoBubble alloc] init] autorelease];
	
	return bubble;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
        // Initialization code
		CGRect bubbleFrame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		self.bubble = [[[BubbleBackgroundView alloc] initWithFrame:bubbleFrame] autorelease];
		[self addSubview:self.bubble];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void)layoutSubviews {
	CGRect bubbleFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
	self.bubble.frame = bubbleFrame;
}

- (void)dealloc {
    [super dealloc];
}


@end

////////////////////////////////////////////////////////////

@implementation BubbleBackgroundView

- (id) initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		NSLog(@"bubble frame: %@", NSStringFromCGRect(frame));
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGPoint origin = self.bounds.origin;
	CGSize size = self.bounds.size;
	
//	CGRect imageBounds = CGRectMake(0.0, 0.0, kBubbleViewWidth, kBubbleViewHeight);
//	CGRect bounds = [self bounds];
	CGContextRef context = UIGraphicsGetCurrentContext();
	UIColor *color;
	CGFloat alignStroke;
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
	alignStroke = fmod(0.5 * stroke, 1.0);
	path = CGPathCreateMutable();
	point = CGPointMake(10.0, 7.0);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(14.0, 3.0);
	controlPoint1 = CGPointMake(10.0, 4.791);
	controlPoint2 = CGPointMake(11.791, 3.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 3.0);
	controlPoint1 = CGPointMake(14.0, 3.0);
	controlPoint2 = CGPointMake(86.0, 3.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 7.0);
	controlPoint1 = CGPointMake(88.209, 3.0);
	controlPoint2 = CGPointMake(90.0, 4.791);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 31.0);
	controlPoint1 = CGPointMake(90.0, 7.0);
	controlPoint2 = CGPointMake(90.0, 31.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 35.0);
	controlPoint1 = CGPointMake(90.0, 33.209);
	controlPoint2 = CGPointMake(88.209, 35.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(59.0, 35.0);
	controlPoint1 = CGPointMake(86.0, 35.0);
	controlPoint2 = CGPointMake(59.0, 35.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(50.0, 44.0);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(41.0, 35.0);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(14.0, 35.0);
	controlPoint1 = CGPointMake(41.0, 35.0);
	controlPoint2 = CGPointMake(14.0, 35.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 31.0);
	controlPoint1 = CGPointMake(11.791, 35.0);
	controlPoint2 = CGPointMake(10.0, 33.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 7.0);
	controlPoint1 = CGPointMake(10.0, 31.0);
	controlPoint2 = CGPointMake(10.0, 7.0);
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
	
	alignStroke = 0.0;
	path = CGPathCreateMutable();
	point = CGPointMake(10.0, 7.0);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(14.0, 3.0);
	controlPoint1 = CGPointMake(10.0, 4.791);
	controlPoint2 = CGPointMake(11.791, 3.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 3.0);
	controlPoint1 = CGPointMake(14.0, 3.0);
	controlPoint2 = CGPointMake(86.0, 3.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 7.0);
	controlPoint1 = CGPointMake(88.209, 3.0);
	controlPoint2 = CGPointMake(90.0, 4.791);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 16.0);
	controlPoint1 = CGPointMake(90.0, 7.0);
	controlPoint2 = CGPointMake(90.0, 16.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 20.0);
	controlPoint1 = CGPointMake(90.0, 18.209);
	controlPoint2 = CGPointMake(88.209, 20.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(14.0, 20.0);
	controlPoint1 = CGPointMake(86.0, 20.0);
	controlPoint2 = CGPointMake(14.0, 20.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 16.0);
	controlPoint1 = CGPointMake(11.791, 20.0);
	controlPoint2 = CGPointMake(10.0, 18.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 7.0);
	controlPoint1 = CGPointMake(10.0, 16.0);
	controlPoint2 = CGPointMake(10.0, 7.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGPathCloseSubpath(path);
	color = [UIColor colorWithRed:0.645 green:0.645 blue:0.645 alpha:0.35];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// emboss top
	
	alignStroke = 0.0;
	path = CGPathCreateMutable();
	point = CGPointMake(10.0, 6.875);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(14.0, 2.875);
	controlPoint1 = CGPointMake(10.0, 4.666);
	controlPoint2 = CGPointMake(11.791, 2.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 2.875);
	controlPoint1 = CGPointMake(14.0, 2.875);
	controlPoint2 = CGPointMake(86.0, 2.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 6.875);
	controlPoint1 = CGPointMake(88.209, 2.875);
	controlPoint2 = CGPointMake(90.0, 4.666);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 7.875);
	controlPoint1 = CGPointMake(90.0, 6.875);
	controlPoint2 = CGPointMake(90.0, 7.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 3.875);
	controlPoint1 = CGPointMake(90.0, 5.666);
	controlPoint2 = CGPointMake(88.209, 3.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(14.0, 3.875);
	controlPoint1 = CGPointMake(86.0, 3.875);
	controlPoint2 = CGPointMake(14.0, 3.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 7.875);
	controlPoint1 = CGPointMake(11.791, 3.875);
	controlPoint2 = CGPointMake(10.0, 5.666);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 6.875);
	controlPoint1 = CGPointMake(10.0, 7.875);
	controlPoint2 = CGPointMake(10.0, 6.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	CGPathCloseSubpath(path);
	color = [UIColor colorWithRed:1 green:1.0 blue:1 alpha:0.4];
	[color setFill];
	CGContextAddPath(context, path);
	CGContextFillPath(context);
	CGPathRelease(path);
	
	// emboss bottom
	
	alignStroke = 0.0;
	path = CGPathCreateMutable();
	point = CGPointMake(10.0, 29.875);
	CGPathMoveToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(14.125, 34.0);
	controlPoint1 = CGPointMake(10.0, 32.084);
	controlPoint2 = CGPointMake(11.916, 34.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(41.0, 34.0);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(50.0, 42.875);
	controlPoint1 = CGPointMake(41.0, 34.0);
	controlPoint2 = CGPointMake(50.0, 42.875);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(59.0, 34.0);
	controlPoint1 = CGPointMake(50.0, 42.875);
	controlPoint2 = CGPointMake(59.0, 34.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 34.0);
	controlPoint1 = CGPointMake(59.0, 34.0);
	controlPoint2 = CGPointMake(86.0, 34.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.125, 30.0);
	controlPoint1 = CGPointMake(88.209, 34.0);
	controlPoint2 = CGPointMake(90.125, 32.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(90.0, 31.0);
	controlPoint1 = CGPointMake(90.125, 30.0);
	controlPoint2 = CGPointMake(90.0, 31.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(86.0, 35.0);
	controlPoint1 = CGPointMake(90.0, 33.209);
	controlPoint2 = CGPointMake(88.209, 35.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(59.0, 35.0);
	controlPoint1 = CGPointMake(86.0, 35.0);
	controlPoint2 = CGPointMake(59.0, 35.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(50.0, 44.0);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(41.0, 35.0);
	CGPathAddLineToPoint(path, NULL, point.x, point.y);
	point = CGPointMake(14.0, 35.0);
	controlPoint1 = CGPointMake(41.0, 35.0);
	controlPoint2 = CGPointMake(14.0, 35.0);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 31.0);
	controlPoint1 = CGPointMake(11.791, 35.0);
	controlPoint2 = CGPointMake(10.0, 33.209);
	CGPathAddCurveToPoint(path, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, point.x, point.y);
	point = CGPointMake(10.0, 29.875);
	controlPoint1 = CGPointMake(10.0, 31.0);
	controlPoint2 = CGPointMake(10.0, 29.875);
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

