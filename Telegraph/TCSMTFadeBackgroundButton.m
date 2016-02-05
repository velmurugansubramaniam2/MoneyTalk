//
//  TCSMTFadeBackgroundButton.m
//  MT
//
//  Created by Andrey Ilskiy on 04/11/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTFadeBackgroundButton.h"

#define kAnimationDuration 0.1f

@interface TCSMTFadeBackgroundButton ()
@end

@implementation TCSMTFadeBackgroundButton

- (void)awakeFromNib
{
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:CGRectGetMidX(self.frame)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.layer setCornerRadius:CGRectGetMidY(self.frame)];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    UIColor *color = highlighted ? [UIColor whiteColor] : [UIColor clearColor];
    
    [UIView animateWithDuration:kAnimationDuration
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^
     {
         self.backgroundColor = color;
     }
                     completion:nil];
}

@end
