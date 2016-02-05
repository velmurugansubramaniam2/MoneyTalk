//
//  TCSName.m
//  TCSP2P
//
//  Created by a.v.kiselev on 13.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSName.h"
#import "TCSAPIDefinitions.h"

@implementation TCSName

@synthesize firstName = _firstName;
@synthesize lastName = _lastName;
@synthesize patronymic = _patronymic;
@synthesize fullName = _fullName;

- (void)clearAllProperties
{
	_firstName = nil;
	_lastName = nil;
    _patronymic = nil;
}

- (NSString *)firstName
{
	if (!_firstName)
	{
		_firstName = [_dictionary objectForKey:kFirstName];
	}

	return _firstName;
}


- (NSString *)lastName
{
	if (!_lastName)
	{
		_lastName = [_dictionary objectForKey:kLastName];
	}

	return _lastName;
}

- (NSString *)patronymic
{
    if (!_patronymic)
    {
        _patronymic = [_dictionary objectForKey:kPatronymic];
    }
    
    return _patronymic;
}

- (NSString *)fullName
{
    NSMutableArray *fullNameChunks = [NSMutableArray new];
	
	if (self.lastName.length > 0)
    {
        [fullNameChunks addObject:self.lastName];
    }

    if (self.firstName.length > 0)
    {
        [fullNameChunks addObject:self.firstName];
    }
    
    if (self.patronymic.length > 0)
    {
        [fullNameChunks addObject:self.patronymic];
    }
    
    return [fullNameChunks componentsJoinedByString:@" "];
}

- (NSString *)firstLastName
{
	NSMutableArray *fullNameChunks = [NSMutableArray new];

    if (self.firstName.length > 0)
    {
        [fullNameChunks addObject:self.firstName];
    }

	if (self.lastName.length > 0)
    {
        [fullNameChunks addObject:self.lastName];
    }

    return [fullNameChunks componentsJoinedByString:@" "];
}

- (NSString *)lastFirstName
{
    NSMutableArray *fullNameChunks = [NSMutableArray new];
    
	if (self.lastName.length > 0)
    {
        [fullNameChunks addObject:self.lastName];
    }
    
    if (self.firstName.length > 0)
    {
        [fullNameChunks addObject:self.firstName];
    }
    
    return [fullNameChunks componentsJoinedByString:@" "];
}

@end
