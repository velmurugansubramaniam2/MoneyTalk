//
//  TCSLCSCardInfo.m
//  TCSiCore
//
//  Created by Max Zhdanov on 13.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSLCSCardInfo.h"
#import "TCSAPIDefinitions.h"

@implementation TCSLCSCardInfo

@synthesize bankLogo = _bankLogo;
@synthesize bankName = _bankName;
@synthesize rusBankName = _rusBankName;

- (void)clearAllProperties
{
    _bankLogo = nil;
    _bankName = nil;
    _rusBankName = nil;
}

- (NSString *)bankLogo
{
    if (!_bankLogo)
    {
        _bankLogo = _dictionary[kBankLogo];
    }
    
    return _bankLogo;
}

- (NSString *)bankName
{
    if (!_bankName)
    {
        _bankName = _dictionary[kBankName];
    }
    
    return _bankName;
}

- (NSString *)rusBankName
{
    if (!_rusBankName)
    {
        _rusBankName = _dictionary[kRusBankName];
    }
    
    return _rusBankName;
}

@end
