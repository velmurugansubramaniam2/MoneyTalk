//
//  TCSMTConfig.h
//  TCSMT
//
//  Created by a.v.kiselev on 25.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved. All.
//	dsfg


#pragma mark -
#pragma mark TextField Constants

#define kPlaceholderPhoneNumber						@"+7 (___) ___-__-__"

#pragma mark - 
#pragma mark Decimal Separators

#define kSummDecimalSeparator 	@","
#define kSummMachineDecimalSeparator @"."
#define kSummGroupingSeparator	@" "


#pragma mark
#pragma mark PAYMENTS AND TRANSFERS

#define kPaymentGroupID_Mobile		@"Мобильная связь"
#define kC2COut						@"c2c-out"
#define kP2PTransfers				@"p2p-transfers"
#define kTransferThirdParty			@"transfer-third-party"
#define kTransferInnerThirdParty	@"transfer-inner-third-party"

#pragma mark
#pragma mark Seconds constants

#define kSecondsInAMinute		60
#define kSecondsInAnHour		(kSecondsInAMinute * 60)
#define kSecondsInADay			(kSecondsInAnHour * 24)

#pragma mark
#pragma mark Settings

#define kUpdateRateHourlyDuration kSecondsInAnHour
#define kUpdateRateDailyDuration kSecondsInADay
#define kUpdateRateWeeklyDuration (kUpdateRateDailyDuration * 7)

#define kIsFingerAuthOn             @"isFingerAuthOn"
#define kIsNotFirstLaunchOnIOS8     @"isNotFirstLaunchOnIOS8"

#define kDefaulNumberCharactersPerCardNumberChunk    4
#define kDefaulMaxCardNumberCharacters               16
#define kMaestroMaxCardNumberCharacters              22
#define kMaestroNumberCharactersPerCardNumberChunk   8


