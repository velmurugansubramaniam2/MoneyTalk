//
//  TCSMTPinImageItem.h
//  TCSMT
//
//  Created by Max Zhdanov on 26.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	TCSMTPinItemStateClear = 0,
	TCSMTPinItemStateEntered,
	TCSMTPinItemStateValid,
    TCSMTPinItemStateInvalid
} TCSMTPinItemState;

@interface TCSMTPinImageItem : UIImageView
{
    UIImage *_clearImage;
    UIImage *_enteredImage;
    UIImage *_validImage;
    UIImage *_invalidImage;
}

@property (nonatomic,assign) TCSMTPinItemState pinState;

+ (TCSMTPinImageItem *)newItem;

@end
