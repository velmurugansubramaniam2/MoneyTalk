//
//  TCSPointer.m
//  TCSP2P
//
//  Created by a.v.kiselev on 13.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSPointer.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSPointer

@synthesize networkId = _networkId;
@synthesize networkAccountId = _networkAccountId;
@synthesize name = _name;
@synthesize photo = _photo;

- (void)clearAllProperties
{
	_networkId = nil;
	_networkAccountId = nil;
	_name = nil;
	_photo = nil;
}


- (NSString *)networkId
{
	if (!_networkId)
	{
		_networkId = [_dictionary objectForKey:kNetworkId];
	}

	return _networkId;
}

- (NSString *)networkAccountId
{
	if (!_networkAccountId)
	{
		_networkAccountId = [_dictionary objectForKey:kNetworkAccountId];
	}

	return _networkAccountId;
}

- (TCSName *)name
{
	if (!_name)
	{
		_name = [[TCSName alloc]initWithDictionary:[_dictionary objectForKey:TCSAPIKey_name]];

		if (([self.networkId isEqualToString:kMobile] || [self.networkId isEqualToString:kEmail]) && _name.firstName.length == 0 && _name.lastName.length == 0 && _name.patronymic.length == 0)
		{
			NSMutableDictionary * dictionary = [NSMutableDictionary dictionaryWithDictionary:[_dictionary objectForKey:TCSAPIKey_name]];
			[dictionary setObject:self.networkAccountId forKey:kFirstName];
			[_name setDictionary:dictionary];
		}
	}

	return _name;
}

- (NSString *)photo
{
	if (!_photo)
	{
		_photo = [_dictionary objectForKey:kPhoto];
	}

	return _photo;
}

- (BOOL)isEqual:(id)object
{
    BOOL isEqual = NO;
    
    if (self == object)
    {
        isEqual = YES;
    }
    else
    {
        if ([object isKindOfClass:[TCSPointer class]])
        {
            isEqual = [self isEqualToPointer:object];
        }
    }
    
    return isEqual;
}

- (BOOL)isEqualToPointer:(TCSPointer *)pointer
{
    BOOL isEqualToPointer = ([self.networkId isEqualToString:pointer.networkId]
                             && [self.networkAccountId isEqualToString:pointer.networkAccountId]);
    
    return isEqualToPointer;
}

@end
