//
//  TCSFeedbackPhone.m
//  TCSP2P
//
//  Created by a.v.kiselev on 15.10.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSFeedbackPhone.h"
#import "TCSAPIDefinitions.h"

@implementation TCSFeedbackPhone

@synthesize description = _description;
@synthesize topic = _topic;
@synthesize phoneNumber = _phoneNumber;
@synthesize roamingPhoneNumber = _roamingPhoneNumber;
@synthesize roamingPhoneString = _roamingPhoneString;
@synthesize phoneString = _phoneString;
@synthesize webUrl = _webUrl;

- (void)clearAllProperties
{
	_description = nil;
	_topic = nil;
	_phoneNumber = nil;
	_roamingPhoneNumber = nil;
	_phoneString = nil;
	_webUrl = nil;
}

- (NSString *)description
{
	if (!_description)
	{
		_description = [_dictionary objectForKey:kDescription];
	}

	return _description;
}

- (NSString *)topic
{
	if (!_topic)
	{
		_topic = [_dictionary objectForKey:kTopic];
	}

	return _topic;
}

- (TCSPhoneNumber *)phoneNumber
{
	if (!_phoneNumber)
	{
		_phoneNumber = [[TCSPhoneNumber alloc]initWithDictionary:[_dictionary objectForKey:kPhoneNumber]];
	}

	return _phoneNumber;
}

- (TCSPhoneNumber *)roamingPhoneNumber
{
	if (!_roamingPhoneNumber)
	{
		_roamingPhoneNumber = [[TCSPhoneNumber alloc]initWithDictionary:[_dictionary objectForKey:kRoamingPhoneNumber]];
	}

	return _roamingPhoneNumber;
}

-(NSString *)roamingPhoneString
{
    if (!_roamingPhoneString)
    {
        _roamingPhoneString = [NSString stringWithFormat:@"%@ (%@) %@", self.roamingPhoneNumber.countryCode, self.roamingPhoneNumber.innerCode, self.roamingPhoneNumber.number];
    }
    
    return _roamingPhoneString;
}

- (NSString *)phoneString
{
	if (!_phoneString)
	{
		_phoneString = [NSString stringWithFormat:@"%@ %@ %@", self.phoneNumber.countryCode,self.phoneNumber.innerCode,self.phoneNumber.number];
	}

	return _phoneString;
}

- (NSString *)webUrl
{
	if (!_webUrl)
	{
		_webUrl = _dictionary[kWebUrl];
	}

	return _webUrl;
}

@end
