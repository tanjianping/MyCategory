//
//  NSStringAdditions.m
//  Test
//
//  Created by tan on 13-5-20.
//  Copyright (c) 2013年 tan. All rights reserved.
//

#import "NSStringAdditions.h"

@implementation NSString (NSStringAdditions)

+ (NSString *)UUID
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidStr = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return [(NSString *)uuidStr autorelease];
}

- (void)enumerateRegexMatches:(NSString *)regex
                      options:(NSRegularExpressionOptions)options
                   usingBlock:(void (^)(NSString *match, NSRange matchRange, BOOL *stop))block
{
    if (regex.length == 0 || !block) return;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regex options:options error:nil];
    if (!regex) return;
    [pattern enumerateMatchesInString:self options:kNilOptions range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        block([self substringWithRange:result.range], result.range, stop);
    }];
}

//example: NSLog(@"%@",[@"abcd432e<a>fghi</a>jklmnop4324qabr5654<a />6stu<b />vwxyz" traverseUsingRegularExp:@"<(.*)>.*<\\/\\1>|<[^/]*/>"]);
- (NSArray *)traverseUsingRegularExp:(NSString *)reg
{
	NSMutableArray *result = [NSMutableArray array];
	NSRange range = [self rangeOfString:reg options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])];
    while (range.length>0)
	{
		[result addObject:[NSValue valueWithRange:range]];
		range = NSMakeRange(range.location+range.length, [self length]-(range.location+range.length));
		range = [self rangeOfString:reg options:NSRegularExpressionSearch range:range];
	}
	return result;
}

- (BOOL)matchRegularExp:(NSString *)reg
{
    return [self rangeOfString:reg options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])].length>0;
}

- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)stringFromMD5
{
    if (self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (unsigned int)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return [outputString autorelease];
}

- (NSString *)stringFromSHA1
{
    if (self == nil || [self length] == 0)
        return nil;
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *)encodeForURL
{
    const CFStringRef legalURLCharactersToBeEscaped = CFSTR("!*'();:@&=+$,/?#[]<>\"{}|\\`^% ");
    
    return [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8)) autorelease];
}

- (NSString *)encodeForURLReplacingSpacesWithPlus;
{
    const CFStringRef legalURLCharactersToBeEscaped = CFSTR("!*'();:@&=$,/?#[]<>\"{}|\\`^% ");
    
    NSString *replaced = [self stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSMakeCollectable(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)replaced, NULL, legalURLCharactersToBeEscaped, kCFStringEncodingUTF8)) autorelease];
}

- (NSString *)decodeFromURL
{
    NSString *decoded = [NSMakeCollectable(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8)) autorelease];
    return [decoded stringByReplacingOccurrencesOfString:@"+" withString:@" "];
}

+ (NSString *)toJsonStringWithObject:(id)object options:(NSJSONWritingOptions)options
{
    return [[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:object options:options error:NULL] encoding:NSUTF8StringEncoding] autorelease];
}

- (id)toJsonObjectWithOptions:(NSJSONReadingOptions)options
{
    return [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding] options:options error:NULL];
}

+ (NSString *)toPlistStringWithObject:(id)object format:(NSPropertyListFormat)format
{
    NSData *xmlData = [NSPropertyListSerialization dataWithPropertyList:object format:format options:kNilOptions error:NULL];
    return [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease];
}

- (id)toPlistObjectWithOptions:(NSPropertyListReadOptions)options format:(NSPropertyListFormat)format
{
    NSData *xmlData = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [NSPropertyListSerialization propertyListWithData:xmlData options:options format:&format error:NULL];
}

- (BOOL)isPureInt
{
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (BOOL)isPureFloat
{
    NSScanner *scan = [NSScanner scannerWithString:self];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
    if (self == nil || self.length == 0) {
        return CGSizeZero;
    }
    
     if ([self respondsToSelector:@selector(sizeWithFont:constrainedToSize:lineBreakMode:)]) {
         CGSize textSize = [self sizeWithFont:font
                            constrainedToSize:size
                                lineBreakMode:NSLineBreakByCharWrapping];
         return textSize;
     }
    
    return CGSizeZero;
}

- (CGSize)sizeWithFont:(UIFont *)font
           lineSpacing:(CGFloat)lineSpacing
               kerning:(CGFloat)kerning
                 width:(CGFloat)width
{
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    [mutableAttributes setObject:font forKey:(NSString *)kCTFontAttributeName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    if (lineSpacing != -1)
        paragraphStyle.lineSpacing = lineSpacing;
    
    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    
    if (kerning != -1)
        [mutableAttributes setObject:@(kerning) forKey:(NSString *)kCTKernAttributeName];
    
    CGSize textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:mutableAttributes
                                         context:nil].size;
    return textSize;
}

- (NSAttributedString *)attributedStringWithFont:(UIFont *)font
                                     lineSpacing:(CGFloat)lineSpacing
                                         kerning:(CGFloat)kerning
{
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    [mutableAttributes setObject:font forKey:(NSString *)kCTFontAttributeName];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    
    if (lineSpacing != -1)
        paragraphStyle.lineSpacing = lineSpacing;
    
    [mutableAttributes setObject:paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    
    if (kerning != -1)
        [mutableAttributes setObject:@(kerning) forKey:(NSString *)kCTKernAttributeName];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self attributes:mutableAttributes];
    
    return attributedString;
}

@end
