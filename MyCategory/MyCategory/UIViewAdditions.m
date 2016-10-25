//
//  AppDelegate.h
//  Test
//
//  Created by tan on 13-5-17.
//  Copyright (c) 2013年 tan. All rights reserved.
//

#import "UIViewAdditions.h"

@implementation UIView (UIViewAdditions)

- (void)show:(UIView *)view level:(int)level
{
    for (int i = 0; i < level; i++) {
        printf("   ");
    }
    
    if ([view isKindOfClass:[UIScrollView class]])
        printf("[%d]:%s contentInset: %s minimumZoomScale: %f maximumZoomScale: %f\n", level, [[view description] UTF8String], [NSStringFromUIEdgeInsets([(UIScrollView *)view contentInset]) UTF8String], [(UIScrollView *)view minimumZoomScale], [(UIScrollView *)view maximumZoomScale]);
    else
        printf("[%d]:%s\n", level, [[view description] UTF8String]);
    
    for (UIView *temp in view.subviews) {
        [self show:temp level:level + 1];
    }
}

- (void)showAllSubviews
{
	printf("\n");
	[self show:self level:0];
}

- (void)showViewAndLayer:(UIView *)view level:(int)level
{
	for (int i = 0; i < level; i++) {
		printf("   ");
	}
    
	printf("[%d]:%s\n", level, [[view description] UTF8String]);
    
    for (int i = 0; i < level; i++) {
		printf("   ");
	}
    
    printf("{");
    printf("\n");
    
    [self showLayer:view.layer level:level];
    
    for (int i = 0; i < level; i++) {
		printf("   ");
	}
    
    printf("}\n");
	
	for (UIView *temp in view.subviews) {
		[self showViewAndLayer:temp level:level + 1];
	}
}

- (void)showLayer:(CALayer *)layer level:(int)level
{
    for (int i = 0; i < level; i++) {
		printf("   ");
	}
    
    printf("(%d):%s\n", level, [[layer description] UTF8String]);
    
    for (CALayer *temp in layer.sublayers) {
		[self showLayer:temp level:level + 1];
	}
    
}

- (void)showAllSubviewsAndLayers
{
	printf("\n");
	[self showViewAndLayer:self level:0];
}

- (void)removeAllSubviews
{
    while (self.subviews.count) {
        UIView *child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}

- (void)removeSubviewWithClassName:(NSString *)className
{
    Class subViewClass = NSClassFromString(className);
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:subViewClass]) {
            [subView removeFromSuperview];
        }
    }
}

- (UIViewController *)viewController
{
    for (UIView *next = self; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    
    return nil;
}

- (BOOL)containSubview:(UIView *)view
{
    if ([self isEqual:view]) {
        return YES;
    }
    
    for (UIView *temp in self.subviews) {
		if ([temp containSubview:view]) {
            return YES;
        }
	}
    
    return NO;
}

- (UIView *)subviewWithClassName:(NSString *)className
{
    if ([NSStringFromClass([self class]) isEqualToString:className]) {
        return self;
    }
    
    for (UIView *temp in self.subviews) {
        UIView *ret = [temp subviewWithClassName:className];
		if (ret)
            return ret;
	}
    
    return nil;
}

- (UIView *)subviewWithViewAddress:(NSString *)viewAddress
{
    if ([[NSString stringWithFormat:@"%p", self] isEqualToString:viewAddress]) {
        return self;
    }
    
    for (UIView *temp in self.subviews) {
        UIView *ret = [temp subviewWithViewAddress:viewAddress];
        if (ret)
            return ret;
    }
    
    return nil;
}

- (UIView *)superviewWithClassName:(NSString *)className
{
    UIView *temp = self;
    Class class = NSClassFromString(className);
    while (temp && ![temp isMemberOfClass:class])
        temp = temp.superview;
    
    return temp;
}

- (UIImage *)snapshotImage
{
    UIImage *image = nil;
    
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0);
        [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    } else {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0);
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;
}

- (UIImage *)gradientImage
{
    CGFloat colors[] = {0.0, 1.0,
                        0.0, 1.0,
                        1.0, 1.0};
    CGSize size = self.frame.size;
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	CGContextRef context = CGBitmapContextCreate(nil, size.width, size.height, 8, 0, colorSpace, kCGBitmapByteOrderDefault);
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, (sizeof(colors) / sizeof(colors[0])) >> 1);
	CGColorSpaceRelease(colorSpace);
    
	CGPoint p2 = CGPointZero;
	CGPoint p1 = CGPointMake(0, size.height);
	CGContextDrawLinearGradient(context, gradient, p1, p2, kCGGradientDrawsAfterEndLocation);
	CGImageRef mask = CGBitmapContextCreateImage(context);
	CFRelease(gradient);
	CGContextRelease(context);

    UIImage *selfImage = [self snapshotImage];
    
	CGImageRef imageWithMask = CGImageCreateWithMask(selfImage.CGImage, mask);
	UIImage *result = [UIImage imageWithCGImage:imageWithMask];
    CFRelease(imageWithMask);
    CFRelease(mask);
    
    return result;
}

#define REFLECTION_MARGIN           3

- (void)addReflectionEffect
{
	self.clipsToBounds = NO;
	UIImage *image = [self gradientImage];
    
    [self removeReflectionEffect];
	
	UIImageView *reflection = [[UIImageView alloc] initWithImage:image];
    reflection.transform = CGAffineTransformMakeScale(1, -0.8);
    reflection.alpha = 0.5;
	reflection.frame = CGRectMake(0.0f, self.frame.size.height + REFLECTION_MARGIN, self.bounds.size.width, self.bounds.size.height);

	[self addSubview:reflection];
	[reflection release];
}

- (void)removeReflectionEffect
{
    for (UIView *temp in self.subviews) {
        if ([temp isKindOfClass:[UIImageView class]] &&
            temp.frame.origin.y == self.frame.size.height + REFLECTION_MARGIN) {
            [temp removeFromSuperview];
        }
    }
}

- (UIView *)deepCopy
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [(UIView *)[NSKeyedUnarchiver unarchiveObjectWithData:data] retain];
}

- (CGFloat)screenOffsetX {
    CGFloat x = 0;
    for (UIView *view = self; view; view = view.superview) {
        x += view.frame.origin.x;
    }
    return x;
}

- (CGFloat)screenOffsetY {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.frame.origin.y;
    }
    return y;
}

- (CGFloat)screenX {
    CGFloat x = 0;
    for (UIView *view = self; view; view = view.superview) {
        x += view.frame.origin.x;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            x -= scrollView.contentOffset.x;
        }
    }
    return x;
}

- (CGFloat)screenY {
    CGFloat y = 0;
    for (UIView *view = self; view; view = view.superview) {
        y += view.frame.origin.y;
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            y -= scrollView.contentOffset.y;
        }
    }
    return y;
}

- (CGPoint)offsetFromView:(UIView *)otherView
{
    CGFloat x = 0, y = 0;
    for (UIView *view = self; view && view != otherView; view = view.superview) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
    }
    return CGPointMake(x, y);
}

- (void)addBorderWithWidth:(CGFloat)borderWidth color:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
    self.layer.borderWidth = borderWidth;
}

- (void)addCornerWithRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = YES;
}

- (void)addShadowWithColor:(UIColor *)color offset:(CGSize)offset radius:(CGFloat)radius
{
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 1;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.layer.masksToBounds = NO;
}

@end
