//
//  TCSAccountsFlatList.m
//  TCSiCore
//
//  Created by Max Zhdanov on 12.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAccountsFlatList.h"
#import "TCSAccount.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"


@implementation TCSAccountsFlatList

@synthesize accountsFlatList = _accountsFlatList;
@synthesize walletAccount = _walletAccount;
@synthesize externalCards = _externalCards;
@synthesize primaryCard = _primaryCard;
@synthesize prepaidCard = _prepaidCard;
@synthesize prepaidCardLCS = _prepaidCardLCS;
@synthesize externalCardsWithoutPrepaidCard = _externalCardsWithoutPrepaidCard;

- (void)clearAllProperties
{
    _accountsFlatList = nil;
    _externalCards = nil;
    _externalCardsWithoutPrepaidCard = nil;
    _primaryCard = nil;
    _prepaidCard = nil;
    _prepaidCardLCS = nil;
    _walletAccount = nil;
}

- (NSArray *)accountsFlatList
{
    if (!_accountsFlatList)
    {
        NSMutableArray *accountsFlatList = [NSMutableArray array];
        
        for (NSDictionary *accountDic in _dictionary)
        {
            TCSAccount *account = [[TCSAccount alloc] initWithDictionary:accountDic];
            [accountsFlatList addObject:account];
        }
        
        _accountsFlatList = [NSArray arrayWithArray:accountsFlatList];
    }
    
    return _accountsFlatList;
}

- (TCSAccount *)walletAccount
{
    if (!_walletAccount)
    {
        NSArray * accountsFlatList = [self accountsFlatList];
        
        for (TCSAccount * account in accountsFlatList)
        {
            if ([[account accountType] isEqualToString:TCSAPIKey_Wallet])
            {
                _walletAccount = account;
                return _walletAccount;
            }
        }
    }
    
    return _walletAccount;
}

- (NSArray *)externalCards
{
    if (!_externalCards)
    {
        NSMutableArray *externalCards = [NSMutableArray array];
        
        NSArray * accountsFlatList = [self accountsFlatList];
        
        for (TCSAccount *account in accountsFlatList)
        {
            if ([[account accountType] isEqualToString:TCSAPIKey_ExternalAccount])
            {
                for (TCSCard *card in [account cards])
                {
                    [externalCards addObject:card];
                    
                    if ([card primary])
                    {
                        _primaryCard = card;
                    }
                }
            }
        }
        
        _externalCards = [NSArray arrayWithArray:externalCards];
    }
    
    return _externalCards;
}

- (NSArray *)externalCardsWithoutPrepaidCard
{
    if (!_externalCardsWithoutPrepaidCard)
    {
        NSMutableArray *externalCardsWithoutPrepaidCard = [NSMutableArray array];
        
        TCSCard *prepaidCard = [self prepaidCard];
        
        NSArray *externalCards = [self externalCards];
        
        for (TCSCard *card in externalCards)
        {
            if (![[card value] isEqualToString:[prepaidCard value]])
            {
                [externalCardsWithoutPrepaidCard addObject:card];
            }
        }
        
        _externalCardsWithoutPrepaidCard = [NSArray arrayWithArray:externalCardsWithoutPrepaidCard];
    }
    
    return _externalCardsWithoutPrepaidCard;
}

- (TCSCard *)prepaidCard
{
    if (!_prepaidCard)
    {
        NSArray * accountsFlatList = [self accountsFlatList];
        
        for (TCSAccount *account in accountsFlatList)
        {
            if ([[account accountType] isEqualToString:TCSAPIKey_Wallet])
            {
                for (TCSCard *card in [account cards])
                {
                    if ([[card statusCode] isEqualToString:kNORM])
                    {
                        if (!_prepaidCard || [[_prepaidCard expiration] milliseconds] < [[card expiration] milliseconds])
                        {
                            _prepaidCard = card;
                        }
                    }
                }
            }
        }
    }
    
    return _prepaidCard;
}

- (TCSCard *)prepaidCardLCS
{
    if (!_prepaidCardLCS)
    {
        NSArray * externalCards = [self externalCards];
        
        for (TCSCard *card in externalCards)
        {
            if ([[card value] isEqualToString:[[self prepaidCard] value]])
            {
                if (!_prepaidCardLCS || [[_prepaidCardLCS expiration] milliseconds] < [[card expiration] milliseconds])
                {
                    _prepaidCardLCS = card;
                }
            }
        }
    }
    
    return _prepaidCardLCS;
}

- (TCSCard *)primaryCard
{
    if (!_externalCards)
    {
        [self externalCards];
    }
    
    return _primaryCard;
}

- (TCSAccount *)accountForCard:(TCSCard *)card
{
    TCSAccount *accountForCard = nil;
    NSArray * accountsFlatList = [self accountsFlatList];
    
    for (TCSAccount *account in accountsFlatList)
    {
        if ([[account accountType] isEqualToString:TCSAPIKey_Wallet])
        {
            for (TCSCard *accountCard in [account cards])
            {
                if ([accountCard.value isEqualToString:card.value])
                {
                    accountForCard = account;
                    break;
                }
            }
        }
    }
    
    return accountForCard;
}

- (BOOL)isCardPrepaid:(TCSCard *)card
{
    return [[[self prepaidCard] value] isEqualToString:[card value]];
}

- (BOOL)isPrepaidCardAttached
{
    NSArray *lcsCards = [self externalCards];
    
    for (TCSCard *card in lcsCards)
    {
        if ([self isCardPrepaid:card])
        {
            return YES;
        }
    }
    
    return NO;
}

- (TCSCard *)cardWithCardId:(NSString *)cardId
{
    if (cardId)
    {
        for (TCSAccount *account in [self accountsFlatList])
        {
            NSArray * cards = [account cards];
            for (TCSCard * card in cards)
            {
                NSString * cardIdentifier = [card identifier];
                if ([cardIdentifier isEqual:cardId])
                {
                    return card;
                }
            }
        }
    }
    
    return nil;
}

@end
