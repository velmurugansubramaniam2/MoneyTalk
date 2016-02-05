//
//  TCSAccountRequisites.m
//  TCSP2P
//
//  Created by a.v.kiselev on 21.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAccountRequisites.h"
#import "TCSAPIDefinitions.h"

@implementation TCSAccountRequisites

@synthesize recipient = _recipient;
@synthesize cardImage = _cardImage;
@synthesize cardLine1 = _cardLine1;
@synthesize correspondentAccountNumber = _correspondentAccountNumber;
@synthesize kpp = _kpp;
@synthesize recipientExternalAccount = _recipientExternalAccount;
@synthesize cardLine2 = _cardLine2;
@synthesize inn = _inn;
@synthesize beneficiaryInfo = _beneficiaryInfo;
@synthesize beneficiaryBank = _beneficiaryBank;
@synthesize bankBik = _bankBik;


- (void)clearAllProperties
{
	_recipient = nil;
	_cardImage = nil;
	_cardLine1 = nil;
	_kpp = nil;
	_recipientExternalAccount = nil;
	_cardLine2 = nil;
	_inn = nil;
	_beneficiaryInfo = nil;
	_beneficiaryBank = nil;
	_bankBik = nil;
}

- (NSString *)recipient
{
	if (!_recipient)
	{
		_recipient = _dictionary[kRecipient];
	}

	return _recipient;
}

- (NSString *)cardImage
{
	if (!_cardImage)
	{
		_cardImage = _dictionary[kCardImage];
	}

	return _cardImage;
}

- (NSString *)cardLine1
{
	if (!_cardLine1)
	{
		_cardLine1 = _dictionary[kCardLine1];
	}

	return _cardLine1;
}

- (NSString *)correspondentAccountNumber
{
	if (!_correspondentAccountNumber)
	{
		_correspondentAccountNumber = _dictionary[kCorrespondentAccountNumber];
	}

	return _correspondentAccountNumber;
}

- (NSString *)kpp
{
	if (!_kpp)
	{
		_kpp = _dictionary[kKpp];
	}

	return _kpp;
}

- (NSString *)recipientExternalAccount
{
	if (!_recipientExternalAccount)
	{
		_recipientExternalAccount = _dictionary[kRecipientExternalAccount];
	}

	return _recipientExternalAccount;
}

- (NSString *)cardLine2
{
	if (!_cardLine2)
	{
		_cardLine2 = _dictionary[kCardLine2];
	}

	return _cardLine2;
}

- (NSString *)inn
{
	if (!_inn)
	{
		_inn = _dictionary[kInn];
	}

	return _inn;
}

- (NSString *)beneficiaryInfo
{
	if (!_beneficiaryInfo)
	{
		_beneficiaryInfo = _dictionary[kBeneficiaryInfo];
	}

	return _beneficiaryInfo;
}

- (NSString *)beneficiaryBank
{
	if (!_beneficiaryBank)
	{
		_beneficiaryBank = _dictionary[kBeneficiaryBank];
	}

	return _beneficiaryBank;
}

- (NSString *)bankBik
{
	if (!_bankBik)
	{
		_bankBik = _dictionary[kBankBik];
	}

	return _bankBik;
}





@end
