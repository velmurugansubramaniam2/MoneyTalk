//
//  TCSFeedbackPhonesList.h
//  TCSP2P
//
//  Created by a.v.kiselev on 15.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSFeedbackPhone.h"

@interface TCSFeedbackPhonesList : TCSBaseObject

@property (nonatomic, strong, readonly) NSArray * feedbackPhonesList;
@property (nonatomic, strong, readonly) TCSFeedbackPhone * walletFeedbackPhone;

@end
