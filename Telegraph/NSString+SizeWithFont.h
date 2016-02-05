//
//  NSString+SizeWithFont.h
//  TCSP2P
//
//  Created by a.v.kiselev on 25/11/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (SizeWithFont)

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constraintSize;
- (CGSize)sizeForLabelWithFont:(UIFont *)font constrainedToSize:(CGSize)constraintSize;
@end
