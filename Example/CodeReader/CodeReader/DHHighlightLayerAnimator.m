//
//  DHHighlightLayerAnimator.m
//  CodeReader
//
//  Created by David Hdz on 1/20/14.
//  Copyright (c) 2014 David Hernandez. All rights reserved.
//

#import "DHHighlightLayerAnimator.h"

@implementation DHHighlightLayerAnimator

static DHHighlightLayerAnimator *sharedHighlightLayerAnimator = nil;

+ (instancetype)sharedAnimator
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		if (!sharedHighlightLayerAnimator) {
			sharedHighlightLayerAnimator = [DHHighlightLayerAnimator new];
			sharedHighlightLayerAnimator.highlightLayer = [sharedHighlightLayerAnimator defaultHighlightLayer];
		}
	});
	return sharedHighlightLayerAnimator;
}

- (void)animateHighlightLayerToFrame:(CGRect)layerFrame
{
	CABasicAnimation *frameAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
	frameAnimation.duration = 0.4f;
	frameAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	frameAnimation.fromValue = [NSValue valueWithCGRect:self.highlightLayer.frame];
	frameAnimation.toValue = [NSValue valueWithCGRect:layerFrame];
	[self.highlightLayer setFrame:layerFrame];
	[self.highlightLayer addAnimation:frameAnimation forKey:@"bounds"];
}

- (CALayer *)defaultHighlightLayer
{
	CALayer *highlightLayer = [CALayer layer];
	[highlightLayer setFrame:CGRectZero];
	[highlightLayer setBorderWidth:3.f];
	[highlightLayer setBorderColor:[UIColor redColor].CGColor];
	return highlightLayer;
}

- (void)setContainerView:(UIView *)containerView
{
	if (_containerView != containerView) {
		_containerView = containerView;
		[_containerView.layer addSublayer:self.highlightLayer];
	}
}

- (void)setHighlightLayer:(CALayer *)highlightLayer
{
	if (_highlightLayer != highlightLayer) {
		_highlightLayer = highlightLayer;
		if (_containerView) {
			[_containerView.layer addSublayer:_highlightLayer];
		} else {
			NSLog(@"Error: Set up a container view first!");
		}
	}
}
@end
