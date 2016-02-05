//
//  TCSP2PGroupsList.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAccountGroupsList.h"
#import "TCSAccountsGroup.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSAccountGroupsList

@synthesize groupsArray = _groupsArray;
@synthesize walletAccount = _walletAccount;
@synthesize externalCards = _externalCards;
@synthesize externalCardsFirstPrimary = _externalCardsFirstPrimary;

- (void)clearAllProperties
{
	_groupsArray = nil;
	_walletAccount = nil;
    _externalCards = nil;
	_externalCardsFirstPrimary = nil;
}
 
- (NSArray *)groupsArray
{
	if (!_groupsArray)
	{
		NSArray * groupsDictionaries = [_dictionary objectForKey:TCSAPIKey_payload];
		NSMutableArray * groupsFromDictionaries = [NSMutableArray array];

		for (NSDictionary * groupDictionary in groupsDictionaries)
		{
			TCSAccountsGroup * group = [[TCSAccountsGroup alloc]initWithDictionary:groupDictionary];
			[groupsFromDictionaries addObject:group];
		}

		_groupsArray = [NSArray arrayWithArray:groupsFromDictionaries];
	}
	
	return _groupsArray;
}

- (TCSAccount *)walletAccount
{
	if (!_walletAccount)
	{
		NSArray * groupsArray = [self groupsArray];

		for (TCSAccountsGroup * group in groupsArray)
		{
			for (TCSAccount * account in [group accounts])
			{
				if ([[account accountType] isEqualToString:TCSAPIKey_Wallet])
				{
					_walletAccount = account;
					return _walletAccount;
				}
			}
		}
	}

	return _walletAccount;
}

- (NSArray *)externalCardsFirstPrimary
{
	if (!_externalCardsFirstPrimary)
	{
		NSMutableArray *externalCards = [NSMutableArray new];

		NSArray * groupsArray = [self groupsArray];

		for (TCSAccountsGroup * group in groupsArray)
		{
			for (TCSAccount * account in [group accounts])
			{
				if ([[account accountType] isEqualToString:kAccountTypeExternal])
				{
					TCSCard * card = [account card];
					if (card.primary)
					{
						[externalCards insertObject:account atIndex:0];
					}
					else
					{
						[externalCards addObject:account];
					}
				}
			}
		}

		_externalCardsFirstPrimary = externalCards.copy;
	}

	return _externalCardsFirstPrimary;
}

- (NSArray *)externalCards
{
    if (!_externalCards)
    {
        NSMutableArray *externalCards = [NSMutableArray new];
        
        NSArray * groupsArray = [self groupsArray];
        
		for (TCSAccountsGroup * group in groupsArray)
		{
			for (TCSAccount * account in [group accounts])
			{
				if ([[account accountType] isEqualToString:TCSAPIKey_ExternalAccount])
				{
					[externalCards addObject:account];
				}
			}
		}
        
        _externalCards = externalCards.copy;
    }
    
    return _externalCards;
}

- (TCSCard *)primaryCard
{
    TCSCard *result = nil;
    
    for (TCSAccount *account in [self externalCards])
    {
        for (TCSCard *card in [account cards])
        {
            if ([card primary])
            {
                result = card;
            }
        }
    }
    
    return result;
}

- (TCSAccount *)primaryAccount
{
    TCSAccount *result = nil;
    
    for (TCSAccount *account in [self externalCards])
    {
        for (TCSCard *card in [account cards])
        {
            if ([card primary])
            {
                result = account;
                break;
            }
        }
    }
    
    return result;
}

@end
