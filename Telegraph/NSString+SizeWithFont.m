//
//  NSString+SizeWithFont.m
//  TCSP2P
//
//  Created by a.v.kiselev on 25/11/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSString+SizeWithFont.h"

@implementation NSString (SizeWithFont)

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constraintSize
{
    CGRect rect = [self boundingRectWithSize:constraintSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:NULL];

	return rect.size;
}

- (CGSize)sizeForLabelWithFont:(UIFont *)font constrainedToSize:(CGSize)constraintSize
{
	CGSize size = [self sizeWithFont:font constrainedToSize:constraintSize];

	size.width = (CGFloat)ceil(size.width);
	size.height = (CGFloat)ceil(size.height);

	return size;
}

@end
