//
//  GNPinAnnotationView.m
//  MapKitDragAndDrop
//
//  Created by iComps on 2/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>	// For CGPointZero
#import <QuartzCore/QuartzCore.h>		// For CAAnimation
#import "GNPinAnnotationView.h"
#import "GNMutablePlacemark.h"

@interface GNPinAnnotationView ()

// Properties that don't need to be seen by the outside world.

@property (nonatomic, assign) BOOL				isMoving;
@property (nonatomic, assign) CGPoint			startLocation;
@property (nonatomic, assign) CGPoint			originalCenter;
@property (nonatomic, retain) UIImageView *		pinShadow;

// Forward declarations

+ (CAAnimation *)_pinBounceAnimation;
+ (CAAnimation *)_pinFloatingAnimation;
+ (CAAnimation *)_pinLiftAnimation;
+ (CAAnimation *)_liftForDraggingAnimation; // Used in touchesBegan:
+ (CAAnimation *)_liftAndDropAnimation;		// Used in touchesEnded: with touchesMoved: triggered
@end

#pragma mark -
#pragma mark DDAnnotationView implementation

@implementation GNPinAnnotationView

+ (CAAnimation *)_pinBounceAnimation {
	
	CAKeyframeAnimation *pinBounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	
	NSMutableArray *values = [NSMutableArray array];
	[values addObject:(id)[UIImage imageNamed:@"PinDown1Purple.png"].CGImage];
	[values addObject:(id)[UIImage imageNamed:@"PinDown2Purple.png"].CGImage];
	[values addObject:(id)[UIImage imageNamed:@"PinDown3Purple.png"].CGImage];
	
	[pinBounceAnimation setValues:values];
	pinBounceAnimation.duration = 0.1;
	
	return pinBounceAnimation;
}

+ (CAAnimation *)_pinFloatingAnimation {
	
	CAKeyframeAnimation *pinFloatingAnimation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	
	[pinFloatingAnimation setValues:[NSArray arrayWithObject:(id)[UIImage imageNamed:@"PinFloatingPurple.png"].CGImage]];
	pinFloatingAnimation.duration = 0.2;
	
	return pinFloatingAnimation;
}

+ (CAAnimation *)_pinLiftAnimation {
	
	CABasicAnimation *liftAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
	
	liftAnimation.byValue = [NSValue valueWithCGPoint:CGPointMake(0.0, -39.0)];	
	liftAnimation.duration = 0.2;
	
	return liftAnimation;
}

+ (CAAnimation *)_liftForDraggingAnimation {
	
	CAAnimation *pinBounceAnimation = [GNPinAnnotationView _pinBounceAnimation];	
	CAAnimation *pinFloatingAnimation = [GNPinAnnotationView _pinFloatingAnimation];
	pinFloatingAnimation.beginTime = pinBounceAnimation.duration;
	CAAnimation *pinLiftAnimation = [GNPinAnnotationView _pinLiftAnimation];	
	pinLiftAnimation.beginTime = pinBounceAnimation.duration;
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:pinBounceAnimation, pinFloatingAnimation, pinLiftAnimation, nil];
	group.duration = pinBounceAnimation.duration + pinFloatingAnimation.duration;
	group.fillMode = kCAFillModeForwards;
	group.removedOnCompletion = NO;
	
	return group;
}

+ (CAAnimation *)_liftAndDropAnimation {
	
	CAAnimation *pinLiftAndDropAnimation = [GNPinAnnotationView _pinLiftAnimation];
	CAAnimation *pinFloatingAnimation = [GNPinAnnotationView _pinFloatingAnimation];
	CAAnimation *pinBounceAnimation = [GNPinAnnotationView _pinBounceAnimation];
	pinBounceAnimation.beginTime = pinFloatingAnimation.duration;
	
	CAAnimationGroup *group = [CAAnimationGroup animation];
	group.animations = [NSArray arrayWithObjects:pinLiftAndDropAnimation, pinFloatingAnimation, pinBounceAnimation, nil];
	group.duration = pinFloatingAnimation.duration + pinBounceAnimation.duration;	
	
	return group;	
}

@synthesize isMoving = _isMoving;
@synthesize startLocation = _startLocation;
@synthesize originalCenter = _originalCenter;
@synthesize pinShadow = _pinShadow;
@synthesize mapView = _mapView;

#pragma mark -
#pragma mark View boilerplate

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	
	if ((self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])) {
		self.canShowCallout = YES;
		
		self.image = [UIImage imageNamed:@"PinPurple.png"];
		self.centerOffset = CGPointMake(8, -10);
		self.calloutOffset = CGPointMake(-8, 0);
		
		_pinShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinShadow.png"]];
		_pinShadow.frame = CGRectMake(0, 0, 32, 39);
		_pinShadow.hidden = YES;
		[self addSubview:_pinShadow];
	}
	return self;
}

- (void)dealloc {
	[_pinShadow release];
	_pinShadow = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIView animation delegates

- (void)shadowLiftWillStart:(NSString *)animationID context:(void *)context {
	self.pinShadow.hidden = NO;
}

- (void)shadowDropDidStop:(NSString *)animationID context:(void *)context {
	self.pinShadow.hidden = YES;
}

#pragma mark -
#pragma mark Handling events

// Reference: iPhone Application Programming Guide > Device Support > Displaying Maps and Annotations > Displaying Annotations > Handling Events in an Annotation View

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {	
	
	if (_mapView) {
		[self.layer removeAllAnimations];
		
		[self.layer addAnimation:[GNPinAnnotationView _liftForDraggingAnimation] forKey:@"DDPinAnimation"];
		
		[UIView beginAnimations:@"DDShadowLiftAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationWillStartSelector:@selector(shadowLiftWillStart:context:)];
		[UIView setAnimationDelay:0.1];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(80, -20);
		self.pinShadow.alpha = 1;
		[UIView commitAnimations];
	}
	
	// The view is configured for single touches only.
    UITouch* aTouch = [touches anyObject];
    _startLocation = [aTouch locationInView:[self superview]];
    _originalCenter = self.center;
	
    [super touchesBegan:touches withEvent:event];	
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
    UITouch* aTouch = [touches anyObject];
    CGPoint newLocation = [aTouch locationInView:[self superview]];
    CGPoint newCenter;
	
	// If the user's finger moved more than 5 pixels, begin the drag.
    if ((abs(newLocation.x - _startLocation.x) > 5.0) || (abs(newLocation.y - _startLocation.y) > 5.0)) {
		_isMoving = YES;		
	}
	
	// If dragging has begun, adjust the position of the view.
    if (_mapView && _isMoving) {
		
        newCenter.x = _originalCenter.x + (newLocation.x - _startLocation.x);
        newCenter.y = _originalCenter.y + (newLocation.y - _startLocation.y);
		
        self.center = newCenter;
    } else {
		// Let the parent class handle it.
        [super touchesMoved:touches withEvent:event];		
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if (_mapView) {
		if (_isMoving) {
			
			[self.layer addAnimation:[GNPinAnnotationView _liftAndDropAnimation] forKey:@"DDPinAnimation"];		
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowLiftDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop:context:)];
			[UIView setAnimationDuration:0.1];
			self.pinShadow.center = CGPointMake(90, -30);
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];		
			
			// Update the map coordinate to reflect the new position.
			CGPoint newCenter;
			newCenter.x = self.center.x - self.centerOffset.x;
			newCenter.y = self.center.y - self.centerOffset.y - self.image.size.height;
			
			GNMutablePlacemark* theAnnotation = (GNMutablePlacemark *)self.annotation;
			CLLocationCoordinate2D newCoordinate = [_mapView convertPoint:newCenter toCoordinateFromView:self.superview];
			theAnnotation.coordinate = newCoordinate;
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"DDAnnotationCoordinateDidChangeNotification" object:theAnnotation];
			
			// Clean up the state information.
			_startLocation = CGPointZero;
			_originalCenter = CGPointZero;
			_isMoving = NO;
		} else {
			
			// TODO: Currently no drop down effect but pin bounce only 
			[self.layer addAnimation:[GNPinAnnotationView _pinBounceAnimation] forKey:@"DDPinAnimation"];
			
			// TODO: animation out-of-sync with self.layer
			[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop:context:)];
			[UIView setAnimationDuration:0.2];
			self.pinShadow.center = CGPointMake(16.0, 19.5);
			self.pinShadow.alpha = 0;
			[UIView commitAnimations];		
		}		
	} else {
		[super touchesEnded:touches withEvent:event];
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
    if (_mapView) {
		// TODO: Currently no drop down effect but pin bounce only 
		[self.layer addAnimation:[GNPinAnnotationView _pinBounceAnimation] forKey:@"DDPinAnimation"];
		
		// TODO: animation out-of-sync with self.layer
		[UIView beginAnimations:@"DDShadowDropAnimation" context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(shadowDropDidStop:context:)];
		[UIView setAnimationDuration:0.2];
		self.pinShadow.center = CGPointMake(16.0, 19.5);
		self.pinShadow.alpha = 0;
		[UIView commitAnimations];		
		
		if (_isMoving) {
			// Move the view back to its starting point.
			self.center = _originalCenter;
			
			// Clean up the state information.
			_startLocation = CGPointZero;
			_originalCenter = CGPointZero;
			_isMoving = NO;			
		}		
    } else {
        [super touchesCancelled:touches withEvent:event];		
	}	
}

@end