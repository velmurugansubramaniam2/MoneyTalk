//
//  TCSAccountsList.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAccount.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

#define kIdentificationNotIdentified 0
#define kIdentificationFullIdentified 1
#define kIdentificationShortIdentified 23


@implementation TCSAccount

@synthesize accountId = _accountId;
@synthesize cards = _cards;
@synthesize moneyAmount = _moneyAmount;
@synthesize accountBalance = _accountBalance;
@synthesize partNumber = _partNumber;
@synthesize name = _name;
@synthesize accountType = _accountType;
@synthesize accountIconType = _accountIconType;
@synthesize externalAccountNumber = _externalAccountNumber;
@synthesize dueDate = _dueDate;
@synthesize lastStatementDate = _lastStatementDate;
@synthesize lastStatementDebtAmount = _lastStatementDebtAmount;
@synthesize creditLimit = _creditLimit;
@synthesize currentMinimalPayment = _currentMinimalPayment;
@synthesize debtAmount = _debtAmount;
@synthesize tariffFileHash = _tariffFileHash;
@synthesize totalIncome = _totalIncome;
@synthesize totalExpense = _totalExpense;
@synthesize mainPointer = _mainPointer;
@synthesize identificationState = _identificationState;
@synthesize isIdentified = _isIdentified;

- (void)clearAllProperties
{
	_accountId = nil;
	_cards = nil;
	_moneyAmount = nil;
	_accountBalance = nil;
	_partNumber = nil;
	_name = nil;
	_accountType = nil;
	_accountIconType = nil;
	_externalAccountNumber = nil;
	_dueDate = nil;
	_lastStatementDate = nil;
	_lastStatementDebtAmount = nil;
	_creditLimit = nil;
	_currentMinimalPayment = nil;
	_debtAmount = nil;
	_tariffFileHash = nil;
	_totalIncome = nil;
	_totalExpense = nil;
    _mainPointer = nil;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    
    if (self)
    {
        _identificationState = TCSAccountIdentificationStateUnknow;
    }
    
    return self;
}



- (NSString*)accountId
{
	if (!_accountId)
	{
		_accountId = [_dictionary objectForKey:TCSAPIKey_id];
	}

	return _accountId;
}

- (NSArray *)cards
{
	if (!_cards)
	{
        NSMutableArray *cardNumbersArray = [NSMutableArray array];
        
        for (NSDictionary *cardNumberDic in [_dictionary objectForKey:TCSAPIKey_cardNumbers])
        {
            [cardNumbersArray addObject:[[TCSCard alloc] initWithDictionary:cardNumberDic]];
        }
        
		_cards = [NSArray arrayWithArray:cardNumbersArray];
	}

	return _cards;
}

- (TCSMoneyAmount *)moneyAmount
{
	if (!_moneyAmount)
	{
		_moneyAmount = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:TCSAPIKey_moneyAmount]];
	}

	return _moneyAmount;
}

- (TCSMoneyAmount *)accountBalance
{
	if (!_accountBalance)
	{
		_accountBalance = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:TCSAPIKey_accountBalance]];
	}

	return _accountBalance;
}

- (NSString *)partNumber
{
	if (!_partNumber)
	{
		_partNumber = [_dictionary objectForKey:TCSAPIKey_partNumber];
	}

	return _partNumber;
}

- (NSString *)name
{
	if (!_name)
	{
		_name = [_dictionary objectForKey:TCSAPIKey_name];
	}

	return _name;
}

- (NSString *)accountType
{
	if (!_accountType)
	{
		_accountType = [_dictionary objectForKey:TCSAPIKey_accountType];
	}

	return _accountType;
}

- (NSString *)accountIconType
{
	if (!_accountIconType)
	{
		_accountIconType = [_dictionary objectForKey:TCSAPIKey_accountIconType];
	}

	return _accountIconType;
}

- (NSString *)externalAccountNumber
{
	if (!_externalAccountNumber)
	{
		_externalAccountNumber = [_dictionary objectForKey:TCSAPIKey_externalAccountNumber];
	}

	return _externalAccountNumber;
}

- (TCSMillisecondsTimestamp *)dueDate
{
	if (!_dueDate)
	{
		_dueDate = [[TCSMillisecondsTimestamp alloc]initWithDictionary:[_dictionary objectForKey:TCSAPIKey_dueDate]];
	}

	return _dueDate;
}


- (TCSMillisecondsTimestamp *)lastStatementDate
{
	if (!_lastStatementDate)
	{
		_lastStatementDate = [[TCSMillisecondsTimestamp alloc]initWithDictionary:[_dictionary objectForKey:kLastStatementDate]];
	}

	return _lastStatementDate;
}

- (TCSMoneyAmount *)lastStatementDebtAmount
{
	if (!_lastStatementDebtAmount)
	{
		_lastStatementDebtAmount = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:kLastStatementDebtAmount]];
	}

	return _lastStatementDebtAmount;
}


- (TCSMoneyAmount *)creditLimit
{
	if (!_creditLimit)
	{
		_creditLimit = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:kCreditLimit]];
	}

	return _creditLimit;
}

- (TCSMoneyAmount *)currentMinimalPayment
{
	if (!_currentMinimalPayment)
	{
		_currentMinimalPayment = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:kCurrentMinimalPayment]];
	}

	return _currentMinimalPayment;
}
- (TCSMoneyAmount *)debtAmount
{
	if (!_debtAmount)
	{
		_debtAmount = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:kDebtAmount]];
	}

	return _debtAmount;
}

- (NSString *)tariffFileHash
{
	if (!_tariffFileHash)
	{
		_tariffFileHash = [_dictionary objectForKey:kTariffFileHash];
	}

	return _tariffFileHash;
}

- (TCSMoneyAmount *)totalIncome
{
	if (!_totalIncome)
	{
		_totalIncome = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:kTotalIncome]];
	}

	return _totalIncome;
}

- (TCSMoneyAmount *)totalExpense
{
	if (!_totalExpense)
	{
		_totalExpense = [[TCSMoneyAmount alloc]initWithDictionary:[_dictionary objectForKey:kTotalExpense]];
	}

	return _totalExpense;
}

- (TCSPointer *)mainPointer
{
    if (!_mainPointer)
    {
        _mainPointer = [[TCSPointer alloc] initWithDictionary:_dictionary[kMainPointer]];
    }
    
    return _mainPointer;
}

- (TCSAccountIdentificationState)identificationState
{
    if (_identificationState == TCSAccountIdentificationStateUnknow)
    {
        NSString *identificationState = _dictionary[kIdentificationState];
        
        if ([identificationState integerValue] == kIdentificationNotIdentified)
        {
            _identificationState = TCSAccountIdentificationStateNotIdentified;
        }
        else if ([identificationState integerValue] == kIdentificationFullIdentified)
        {
            _identificationState = TCSAccountIdentificationStateFullIdentified;
        }
        else if ([identificationState integerValue] == kIdentificationShortIdentified)
        {
            _identificationState = TCSAccountIdentificationStateShortIdentified;
        }
    }
    
    return _identificationState;
}



-(BOOL)isIdentified
{
    return self.identificationState != TCSAccountIdentificationStateNotIdentified;
}

- (BOOL)isChargeable
{
	return [_dictionary[kChargeable] boolValue];
}

- (TCSCard *)card
{
    return [[self cards] firstObject];
}

@end
