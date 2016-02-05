//
//  TCSMTPinNumbersView.h
//  TCSMT
//
//  Created by Max Zhdanov on 06.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSMTPinImageItem.h"

@interface TCSMTPinNumbersView : UIView
@property (nonatomic, strong) IBOutletCollection(TCSMTPinImageItem) NSArray *pinImageItems;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;

+ (TCSMTPinNumbersView *)newView;
- (void)setNumbersEntered:(NSUInteger)count;
- (void)setInvalid:(BOOL)isInvalid;

@end
