//
//  TCSP2PGroupsList.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSAccount.h"

@interface TCSAccountGroupsList : TCSBaseObject

@property (nonatomic, strong, readonly) NSArray * groupsArray;
@property (nonatomic, strong, readonly) TCSAccount * walletAccount;
@property (nonatomic, strong, readonly) NSArray *externalCards;
@property (nonatomic, strong, readonly) NSArray *externalCardsFirstPrimary;

- (TCSCard *)primaryCard;
- (TCSAccount *)primaryAccount;

@end
