//
//  DHHighlightLayerAnimator.h
//  CodeReader
//
//  Created by David Hdz on 1/20/14.
//  Copyright (c) 2014 David Hernandez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DHHighlightLayerAnimator : NSObject

@property (strong, nonatomic) CALayer *highlightLayer;
@property (strong, nonatomic) UIView *containerView;

+ (instancetype)sharedAnimator;

- (void)animateHighlightLayerToFrame:(CGRect)layerFrame;

@end
