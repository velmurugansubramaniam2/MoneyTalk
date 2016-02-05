//
//  TCSAccountsList.h
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"
#import "TCSCard.h"
#import "TCSMoneyAmount.h"
#import "TCSMillisecondsTimestamp.h"
#import "TCSPointer.h"

typedef NS_ENUM(NSInteger, TCSAccountIdentificationState)
{
    TCSAccountIdentificationStateNotIdentified,
    TCSAccountIdentificationStateFullIdentified,
    TCSAccountIdentificationStateShortIdentified,
    TCSAccountIdentificationStateUnknow
};



@interface TCSAccount : TCSBaseObject

@property (nonatomic, strong, readonly) NSString * accountId;
@property (nonatomic, strong, readonly) NSArray * cards;
@property (nonatomic, strong, readonly) TCSMoneyAmount * moneyAmount;
@property (nonatomic, strong, readonly) TCSMoneyAmount * accountBalance;
@property (nonatomic, strong, readonly) NSString * partNumber;
@property (nonatomic, strong, readonly) NSString * name;
@property (nonatomic, strong, readonly) NSString * accountType;
@property (nonatomic, strong, readonly) NSString * accountIconType;
@property (nonatomic, strong, readonly) NSString * externalAccountNumber;
@property (nonatomic, strong, readonly) TCSMillisecondsTimestamp * dueDate;
@property (nonatomic, strong, readonly) TCSMillisecondsTimestamp * lastStatementDate;
@property (nonatomic, strong, readonly) TCSMoneyAmount * lastStatementDebtAmount;
@property (nonatomic, strong, readonly) TCSMoneyAmount * creditLimit;
@property (nonatomic, strong, readonly) TCSMoneyAmount * currentMinimalPayment;
@property (nonatomic, strong, readonly) TCSMoneyAmount * debtAmount;
@property (nonatomic, strong, readonly) NSString * tariffFileHash;
@property (nonatomic, strong, readonly) TCSMoneyAmount * totalIncome;
@property (nonatomic, strong, readonly) TCSMoneyAmount * totalExpense;
@property (nonatomic, strong, readonly) TCSPointer *mainPointer;
@property (nonatomic, assign, readonly) TCSAccountIdentificationState identificationState;
@property (nonatomic, readonly)			BOOL			isIdentified;
@property (nonatomic, readonly)			BOOL			isChargeable;

- (TCSCard *)card;

@end
