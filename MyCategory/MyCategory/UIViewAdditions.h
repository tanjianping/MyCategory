//
//  UIViewAdditions.h
//  Test
//
//  Created by tan on 13-5-17.
//  Copyright (c) 2013年 tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView (UIViewAdditions)

// subview operations
- (void)showAllSubviews;
- (void)showAllSubviewsAndLayers;

- (void)removeAllSubviews;
- (void)removeSubviewWithClassName:(NSString *)className;

// get viewController of view
- (UIViewController *)viewController;

// opposite to isDescendantOfView, returns YES for self.
- (BOOL)containSubview:(UIView *)view;

// find the first subview recursively with className, include self
- (UIView *)subviewWithClassName:(NSString *)className;

// find the first subview recursively with viewAddress, include self
- (UIView *)subviewWithViewAddress:(NSString *)viewAddress;

// find the first superview circularly, include self
- (UIView *)superviewWithClassName:(NSString *)className;

// get image
- (UIImage *)snapshotImage;
- (UIImage *)gradientImage;

// reflection effect
- (void)addReflectionEffect;
- (void)removeReflectionEffect;

// need release or autorelease
- (UIView *)deepCopy;

// return the x, y coordinate on the screen, don't subtract scroll views' contentOffset.
- (CGFloat)screenOffsetX;
- (CGFloat)screenOffsetY;

// return the x , y coordinate on the screen, taking into account scroll views.
- (CGFloat)screenX;
- (CGFloat)screenY;

// calculates the offset of this view from another view in screen coordinates. otherView should be a parent view of this view.
- (CGPoint)offsetFromView:(UIView *)otherView;

// border
- (void)addBorderWithWidth:(CGFloat)borderWidth color:(UIColor *)borderColor;

// corner
- (void)addCornerWithRadius:(CGFloat)cornerRadius;

// shadow
- (void)addShadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius;

@end
