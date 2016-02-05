//
//  TCSFeedbackPhonesList.m
//  TCSP2P
//
//  Created by a.v.kiselev on 15.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSFeedbackPhonesList.h"
#import "TCSFeedbackPhone.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSFeedbackPhonesList

@synthesize feedbackPhonesList = _feedbackPhonesList;
@synthesize walletFeedbackPhone = _walletFeedbackPhone;

- (void)clearAllProperties
{
	_feedbackPhonesList = nil;
	_walletFeedbackPhone = nil;
}

- (NSArray *)feedbackPhonesList
{
	if (!_feedbackPhonesList)
	{
        NSMutableArray *phones = [NSMutableArray array];
        NSArray *phoneDictionariesArray = [_dictionary objectForKey:TCSAPIKey_payload];
        for (NSDictionary *phoneDictionary in phoneDictionariesArray)
        {
            TCSFeedbackPhone *feedbackPhone = [[TCSFeedbackPhone alloc] initWithDictionary:phoneDictionary];
            [phones addObject:feedbackPhone];
        }

        _feedbackPhonesList = [NSArray arrayWithArray:phones];
	}

	return _feedbackPhonesList;
}

- (TCSFeedbackPhone *)walletFeedbackPhone
{
	if (!_walletFeedbackPhone)
	{
		for (TCSFeedbackPhone * feedbackPhone in self.feedbackPhonesList)
        {
			if ([[[feedbackPhone topic] lowercaseString] isEqualToString:kWallet])
			{
				_walletFeedbackPhone = feedbackPhone;
			}
        }
	}

	return _walletFeedbackPhone;
}

@end
