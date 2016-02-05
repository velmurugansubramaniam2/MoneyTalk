//
//  TCSAccountsFlatList.h
//  TCSiCore
//
//  Created by Max Zhdanov on 12.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSCard.h"
#import "TCSAccount.h"

@interface TCSAccountsFlatList : TCSBaseObject

@property (nonatomic, strong, readonly) NSArray * accountsFlatList;
@property (nonatomic, strong, readonly) TCSAccount *walletAccount;

@property (nonatomic, strong, readonly) TCSCard   *prepaidCard;
@property (nonatomic, strong, readonly) TCSCard   *prepaidCardLCS;
@property (nonatomic, strong, readonly) TCSCard   *primaryCard;
@property (nonatomic, strong, readonly) NSArray         *externalCards;
@property (nonatomic, strong, readonly) NSArray         *externalCardsWithoutPrepaidCard;

- (TCSAccount *)accountForCard:(TCSCard *)card;

- (BOOL)isCardPrepaid:(TCSCard *)card;
- (BOOL)isPrepaidCardAttached;

- (TCSCard *)cardWithCardId:(NSString *)cardId;

@end
