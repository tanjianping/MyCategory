//
//  NSStringAdditions.h
//  Test
//
//  Created by tan on 13-5-20.
//  Copyright (c) 2013年 tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>

@interface NSString (NSStringAdditions)

+ (NSString *)UUID;

- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block;
- (NSArray *)traverseUsingRegularExp:(NSString *)reg;
- (BOOL)matchRegularExp:(NSString *)reg;

- (NSString *)trim;

- (NSString *)stringFromMD5;
- (NSString *)stringFromSHA1;

- (NSString *)encodeForURL;
- (NSString *)encodeForURLReplacingSpacesWithPlus;
- (NSString *)decodeFromURL;

+ (NSString *)toJsonStringWithObject:(id)object options:(NSJSONWritingOptions)options;
- (id)toJsonObjectWithOptions:(NSJSONReadingOptions)options;

+ (NSString *)toPlistStringWithObject:(id)object format:(NSPropertyListFormat)format;
- (id)toPlistObjectWithOptions:(NSPropertyListReadOptions)options format:(NSPropertyListFormat)format;

- (BOOL)isPureInt;
- (BOOL)isPureFloat;

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;
- (CGSize)sizeWithFont:(UIFont *)font
           lineSpacing:(CGFloat)lineSpacin   // -1 default
               kerning:(CGFloat)kerning      // -1 default
                 width:(CGFloat)width;

- (NSAttributedString *)attributedStringWithFont:(UIFont *)font
                                     lineSpacing:(CGFloat)lineSpacing   // -1 default
                                         kerning:(CGFloat)kerning;      // -1 default

@end
