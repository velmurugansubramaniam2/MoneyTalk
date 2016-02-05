//
//  Utils.m
//  TCSP2PiPhone
//
//  Created by Вячеслав Владимирович Будников on 12.02.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSUtils.h"

#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>


@implementation TCSUtils

#pragma mark - Word Ending

+ (TCSWordEndingByCountType)wordEndingWithCountOf:(int)count
{
	count = abs(count);
	int countResidue10 = count % 10;

	if ((count <= 20 && count >= 5) || (countResidue10 == 0))
	{
		return TCSWordEndingByCountTypeFrom5To20OrResidue0;
	}

	if (countResidue10 <=4 && countResidue10 >=2)
	{
		return TCSWordEndingByCountTypeResidueFrom2To4;
	}

	return TCSWordEndingByCountTypeResidue1;
}

#pragma mark - Card Helpers

+ (TCSP2PCardType)cardTypeByCardNumberString:(NSString *)cardNumber
{
    TCSP2PCardType result = TCSP2PCardTypeNone;
    int firstNum = cardNumber.length > 0 ? ([cardNumber characterAtIndex:0] - '0') : 0;
    switch (firstNum)
    {
        case 4:
        {
            //Visa
            result = TCSP2PCardTypeVisa;
        }
            break;
        case 2:
        case 5:
        {
            //Mastercard
            result = TCSP2PCardTypeMasterCard;
        }
            break;
        case 6:
        {
            //Maestro
            result = TCSP2PCardTypeMaestro;
        }
            break;

        case 0:
        {
            result = TCSP2PCardTypeCount;
        }
            break;
            
        default:
//            NSAssert(false, @"Invalid card type - should not be reached");
            break;
    }

    return result;
}


@end