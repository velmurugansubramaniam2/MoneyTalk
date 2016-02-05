//
//  TCSP2PGroup.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAccountsGroup.h"
#import "TCSAPIStrings.h"


@implementation TCSAccountsGroup

@synthesize name = _name;
@synthesize accounts = _accounts;

- (void)clearAllProperties
{
	_name = nil;
	_accounts = nil;
}

- (NSString *)name
{
	if (!_name)
	{
		_name = [_dictionary objectForKey:TCSAPIKey_name];
	}

	return _name;
}

- (NSArray*)accounts
{
	if (!_accounts)
	{
		NSArray * accountsDictionaries = [_dictionary objectForKey:TCSAPIKey_accounts];
		NSMutableArray * accountsFromDictionaries = [NSMutableArray array];

		for (NSDictionary * accountDictionary in accountsDictionaries)
		{
			TCSAccount * account = [[TCSAccount alloc]initWithDictionary:accountDictionary];
			[accountsFromDictionaries addObject:account];
		}

		_accounts = [NSArray arrayWithArray:accountsFromDictionaries];
	}

	return _accounts;
}

@end
