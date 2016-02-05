//
//  TCSAccountRequisites.h
//  TCSP2P
//
//  Created by a.v.kiselev on 21.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@interface TCSAccountRequisites : TCSBaseObject

@property (nonatomic, strong) NSString * recipient;
@property (nonatomic, strong) NSString * cardImage;
@property (nonatomic, strong) NSString * cardLine1;
@property (nonatomic, strong) NSString * correspondentAccountNumber;
@property (nonatomic, strong) NSString * kpp;
@property (nonatomic, strong) NSString * recipientExternalAccount;
@property (nonatomic, strong) NSString * cardLine2;
@property (nonatomic, strong) NSString * inn;
@property (nonatomic, strong) NSString * beneficiaryInfo;
@property (nonatomic, strong) NSString * beneficiaryBank;
@property (nonatomic, strong) NSString * bankBik;

@end


