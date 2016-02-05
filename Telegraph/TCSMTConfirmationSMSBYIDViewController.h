//
//  TCSMTConfirmationSMSBYIDViewController.h
//  TCSMT
//
//  Created by Max Zhdanov on 26.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCSMTConfirmationViewController.h"

@interface TCSMTConfirmationSMSBYIDViewController : TCSMTConfirmationViewController
@property (nonatomic, copy) void(^dismissBlock)();
@end
