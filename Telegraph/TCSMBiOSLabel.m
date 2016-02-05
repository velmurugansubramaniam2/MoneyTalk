//
//  TCSMBiOSLabel.m
//  TCSMBiOS
//
//  Created by Max Zhdanov on 23.10.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMBiOSLabel.h"
#import "NSString+SizeWithFont.h"
#import "UIDevice+Helpers.h"

#define kGradientWidth 18.0f

@implementation TCSMBiOSLabel

- (instancetype)init
{
    if (self = [super init])
    {
        [self enableGradientTruncation];
    }
    
    return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];

	[self enableGradientTruncation];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
		[self enableGradientTruncation];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame])
	{
		[self enableGradientTruncation];
	}

	return self;
}

- (void)enableGradientTruncation
{
	[self setAutoresizesSubviews:YES];
	[self setLineBreakMode:NSLineBreakByClipping];
	_gradientLayer = [CAGradientLayer layer];
	_gradientLayer.frame = self.bounds;
	_gradientLayer.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:1] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], nil];
    CGFloat startX = kGradientWidth/self.frame.size.width;
	_gradientLayer.startPoint = CGPointMake(1.0f - startX, 0.0f);
	_gradientLayer.endPoint = CGPointMake(0.99f, 0.0f);
}

- (void)setupLayerTruncation
{
	if ([UIDevice systemVersion_] == 8)
	{
		[self setLineBreakMode:NSLineBreakByTruncatingTail];
		[self.layer setMask:nil];
		return;
	}
	
	if ([self.text length] <= 0)
        return;
	
	[self.layer setMask:nil];

    if (attributedTextSize.width > self.bounds.size.width)
    {
        if (self.numberOfLines == 1)
        {
            [self setupGradientLayer];
        }
        else
        {
			CGSize rect = [self.text sizeForLabelWithFont:self.font constrainedToSize:CGSizeMake(self.frame.size.width, 1000)];
			
            if (rect.height > ceil(self.frame.size.height))
            {
                [self setupGradientLayer];
                
                if (_layerWithoutGradient == nil)
                {
                    _layerWithoutGradient = [CALayer layer];
                    _layerWithoutGradient.backgroundColor = [UIColor blackColor].CGColor;
                    _layerWithoutGradient.opacity = 1.0;
                }
                
                CGRect layerWithoutGradientFrame = self.bounds;
                layerWithoutGradientFrame.size.height -= self.font.lineHeight;
                [_layerWithoutGradient setFrame:layerWithoutGradientFrame];
                [_gradientLayer addSublayer:_layerWithoutGradient];
            }
			else
			{
				if (_layerWithoutGradient)
				{
					[_layerWithoutGradient removeFromSuperlayer];
					_layerWithoutGradient = nil;
				}
			}
        }
    }

}

- (void)setupGradientLayer
{
    [_gradientLayer setFrame:self.bounds];
    CGFloat startX = kGradientWidth/_gradientLayer.frame.size.width;
    _gradientLayer.startPoint = CGPointMake(1.0f - startX, 0.0f);
    _gradientLayer.endPoint = CGPointMake(0.99f, 0.0f);
    [self.layer setMask:_gradientLayer];

	if (_layerWithoutGradient)
	{
		[_layerWithoutGradient removeFromSuperlayer];
		_layerWithoutGradient = nil;
	}
}

- (void)setText:(NSString *)text
{
	[super setText:text];
	
	attributedTextSize = [self.attributedText size];
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
	[super setAttributedText:attributedText];

	attributedTextSize = [self.attributedText size];
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)setFont:(UIFont *)font
{
	[super setFont:font];
	
	[self setupLayerTruncation];
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	[self setupLayerTruncation];
}

@end
