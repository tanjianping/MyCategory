//
//  UIColorAdditions.m
//  Test
//
//  Created by tan on 14-2-21.
//  Copyright (c) 2014年 tan. All rights reserved.
//

#import "UIColorAdditions.h"

@implementation UIColor (UIColorAdditions)

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    const char *pRed = [[hexString substringWithRange:NSMakeRange(0, 2)] UTF8String];
    const char *pGreen = [[hexString substringWithRange:NSMakeRange(2, 2)] UTF8String];
    const char *pBlue = [[hexString substringWithRange:NSMakeRange(4, 2)] UTF8String];
    CGFloat red = strtol(pRed, NULL, 16) / 255.0f;
    CGFloat green = strtol(pGreen, NULL, 16) / 255.0f;
    CGFloat blue = strtol(pBlue, NULL, 16) / 255.0f;
    
    return [UIColor colorWithRed:red
						   green:green
							blue:blue
						   alpha:1.];
}

- (NSString *)hexStringWithAlpha
{
    CGColorRef color = self.CGColor;
    size_t count = CGColorGetNumberOfComponents(color);
    const CGFloat *components = CGColorGetComponents(color);
    static NSString *stringFormat = @"%02x%02x%02x";
    NSString *hex = nil;
    if (count == 2) {
        NSUInteger white = (NSUInteger)(components[0] * 255.0f);
        hex = [NSString stringWithFormat:stringFormat, white, white, white];
    } else if (count == 4) {
        hex = [NSString stringWithFormat:stringFormat,
               (NSUInteger)(components[0] * 255.0f),
               (NSUInteger)(components[1] * 255.0f),
               (NSUInteger)(components[2] * 255.0f)];
    }
    
    if (hex) {
        hex = [hex stringByAppendingFormat:@"%02lx",
               (unsigned long)(CGColorGetAlpha(self.CGColor) * 255.0 + 0.5)];
    }
    return hex;
}

+ (UIColor *)colorWithIntegerRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:red / 255.0f
						   green:green / 255.0f
							blue:blue / 255.0f
						   alpha:alpha];
}

- (BOOL)isEqualToColor:(UIColor *)color
{
    return CGColorEqualToColor(self.CGColor, color.CGColor);
}

@end
