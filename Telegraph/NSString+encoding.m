//
//  NSString+encoding.m
//  TCSiCore
//
//  Created by a.v.kiselev on 08/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSString+encoding.h"

@implementation NSString (encoding)

- (NSString *)encodeURL
{
    NSString *escaped = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)self, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
    
    return escaped;
}

+ (NSStringEncoding)stringEncodingFromEncodingName:(NSString *)stringEncodingName
{
	NSStringEncoding stringEncoding = 0;
	CFStringEncoding aEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)stringEncodingName);
	stringEncoding = CFStringConvertEncodingToNSStringEncoding(aEncoding);

	return stringEncoding;
}

@end
