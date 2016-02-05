//
//  TCSFeedbackPhone.h
//  TCSP2P
//
//  Created by a.v.kiselev on 15.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSPhoneNumber.h"

@interface TCSFeedbackPhone : TCSBaseObject

@property (nonatomic, readonly) NSString * description;
@property (nonatomic, readonly) NSString * topic;
@property (nonatomic, readonly) TCSPhoneNumber * phoneNumber;
@property (nonatomic, readonly) TCSPhoneNumber * roamingPhoneNumber;
@property (nonatomic, readonly) NSString * roamingPhoneString;
@property (nonatomic, readonly) NSString * phoneString;
@property (nonatomic, readonly) NSString * webUrl;

@end
