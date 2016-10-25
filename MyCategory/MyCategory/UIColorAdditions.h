//
//  UIColorAdditions.h
//  Test
//
//  Created by tan on 14-2-21.
//  Copyright (c) 2014年 tan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIColor (UIColorAdditions)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (NSString *)hexStringWithAlpha;

+ (UIColor *)colorWithIntegerRed:(int)red green:(int)green blue:(int)blue alpha:(CGFloat)alpha;

- (BOOL)isEqualToColor:(UIColor *)color;

@end
