//
//  TCSMTPinNumbersView.m
//  TCSMT
//
//  Created by Max Zhdanov on 06.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTPinNumbersView.h"
#import "TGAppearance.h"

@implementation TCSMTPinNumbersView

+ (TCSMTPinNumbersView *)newView
{
	TCSMTPinNumbersView *newView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([TCSMTPinNumbersView class]) owner:self options:nil] objectAtIndex:0];
    if (newView)
    {
    }
	return newView;
}

- (void)setNumbersEntered:(NSUInteger)count
{
    for (NSUInteger i = 0; i < _pinImageItems.count; i++)
    {
        TCSMTPinImageItem *numberImage = [_pinImageItems objectAtIndex:i];
        
        if (i < count)
        {
            [numberImage setPinState:TCSMTPinItemStateEntered];
        }
        else
        {
            [numberImage setPinState:TCSMTPinItemStateClear];
        }
    }
}

- (void)setInvalid:(BOOL)isInvalid
{
    for (NSUInteger i = 0; i < _pinImageItems.count; i++)
    {
        TCSMTPinImageItem *numberImage = [_pinImageItems objectAtIndex:i];
        
        if (isInvalid)
        {
            [numberImage setPinState:TCSMTPinItemStateInvalid];
        }
        else
        {
            [numberImage setPinState:TCSMTPinItemStateValid];
        }
    }
}


@end
