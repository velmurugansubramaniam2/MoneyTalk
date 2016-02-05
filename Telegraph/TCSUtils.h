//
//  TCSUtils.h
//  TCSiCore
//
//  Created by a.v.kiselev on 06.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

#import "TCSMacroses.h"

#pragma mark --------------------
#pragma mark Type definitions
#pragma mark --------------------

typedef enum
{
    TCSP2PCardTypeNone = 0,
    TCSP2PCardTypeVisa,
    TCSP2PCardTypeMasterCard,
    TCSP2PCardTypeMaestro,
    TCSP2PCardTypeCount
}
TCSP2PCardType;

typedef enum
{
	TCSWordEndingByCountTypeResidue1,
	TCSWordEndingByCountTypeFrom5To20OrResidue0,
	TCSWordEndingByCountTypeResidueFrom2To4
}TCSWordEndingByCountType;


@interface TCSUtils : NSObject

#pragma mark - Word Ending

+ (TCSWordEndingByCountType)wordEndingWithCountOf:(int)count;

+ (TCSP2PCardType)cardTypeByCardNumberString:(NSString *)cardNumber;

@end