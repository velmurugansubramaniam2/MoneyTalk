//
//  TCSMTPinImageItem.m
//  TCSMT
//
//  Created by Max Zhdanov on 26.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTPinImageItem.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

@implementation TCSMTPinImageItem

@synthesize pinState = _pinState;

+ (TCSMTPinImageItem *)newItem
{
	TCSMTPinImageItem *imageItem = [[TCSMTPinImageItem alloc]initWithImage:[UIImage imageNamed:@"dot"]];
	[imageItem setStateImages];
	[imageItem setPinState:TCSMTPinItemStateClear];
	return imageItem;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	[self setStateImages];
	[self setPinState:TCSMTPinItemStateClear];
}

- (void)setStateImages
{
    _clearImage = [UIImage imageNamed:@"dot"];
    _enteredImage = [UIImage imageNamed:@"dotblue"];
    _validImage = [UIImage imageNamed:@"dotgreen"];
    _invalidImage = [UIImage imageNamed:@"dotred"];
}

- (void)setPinState:(TCSMTPinItemState)pinState
{
    _pinState = pinState;
    
    switch (_pinState)
    {
        case TCSMTPinItemStateClear:
        {
            self.image = _enteredImage; //_clearImage;
            self.tintColor = [UIColor whiteColor];
        }
            break;
            
        case TCSMTPinItemStateEntered:
        {
            self.image = _enteredImage;
            self.tintColor = [TCSTGTelegramMoneyTalkProxy tgAccentColor];
        }
            break;
            
        case TCSMTPinItemStateValid:
            self.image = _validImage;
            break;
            
        case TCSMTPinItemStateInvalid:
            self.image = _invalidImage;
            break;
            
        default:
            break;
    }
}

@end
