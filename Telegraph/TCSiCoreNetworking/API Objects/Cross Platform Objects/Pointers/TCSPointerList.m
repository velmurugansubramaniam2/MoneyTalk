//
//  TCSPointerList.m
//  TCSP2P
//
//  Created by a.v.kiselev on 13.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSPointerList.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSPointerList

@synthesize pointers = _pointers;
@synthesize pointerTCS = _pointerTCS;
@synthesize pointersWithoutTCS = _pointersWithoutTCS;
@synthesize pointersEmail = _pointersEmail;
@synthesize pointersFacebook =_pointersFacebook;
@synthesize pointersVk = _pointersVk;
@synthesize pointersMobile = _pointersMobile;

- (void)clearAllProperties
{
	_pointers = nil;
	_pointersEmail = nil;
	_pointersWithoutTCS = nil;
	_pointerTCS = nil;
	_pointersMobile = nil;
	_pointersVk = nil;
	_pointersEmail = nil;
}

- (NSArray *)pointers
{
	NSArray * arrayOfPointersDictionaries = [_dictionary objectForKey:TCSAPIKey_payload];
	if (!_pointers && arrayOfPointersDictionaries)
	{
		NSMutableArray * pointersArray = [NSMutableArray array];
		for (NSDictionary * pointerDictionary in arrayOfPointersDictionaries)
		{
			[pointersArray addObject:[[TCSPointer alloc] initWithDictionary:pointerDictionary]];
		}
		_pointers = [NSArray arrayWithArray:pointersArray];
	}

	return _pointers;
}

- (NSArray *)pointersWithoutTCS
{
	if (!_pointersWithoutTCS)
	{
		NSMutableArray * pointers = [NSMutableArray arrayWithArray:[self pointers]];
		[pointers removeObject:[self pointerTCS]];
		_pointersWithoutTCS = [NSArray arrayWithArray:pointers];
	}
	
	return _pointersWithoutTCS;
}

- (TCSPointer *)pointerTCS
{
	if (!_pointerTCS)
	{
		for (TCSPointer * pointer in [self pointers])
		{
			if ([[pointer networkId]isEqualToString:kTcs])
			{
				_pointerTCS = pointer;
				break;
			}
		}
	}

	return _pointerTCS;
}

- (NSArray *)pointersEmail
{
	if (!_pointersEmail)
	{
		_pointersEmail = [self pointersWithNetworkId:kEmail];
	}

	return _pointersEmail;
}

-(NSArray *)pointersVk
{
	if (!_pointersVk)
	{
		_pointersVk = [self pointersWithNetworkId:kVk];
	}
	
	return _pointersVk;
}

-(NSArray *)pointersFacebook
{
	if (!_pointersFacebook)
	{
		_pointersFacebook = [self pointersWithNetworkId:kFb];
	}
	
	return _pointersFacebook;
}

- (NSArray *)pointersMobile
{
	if (!_pointersMobile)
	{
		_pointersMobile = [self pointersWithNetworkId:kMobile];
	} 

	return _pointersMobile;
}

- (NSArray *)pointersWithNetworkId:(NSString*)networkId
{
	NSMutableArray * arrayOfPointers = [NSMutableArray array];
	for (TCSPointer * pointer in self.pointers)
	{
		if ([pointer.networkId isEqualToString:networkId])
		{
			[arrayOfPointers addObject:pointer];
		}
	}

	return [NSArray arrayWithArray:arrayOfPointers];
}

@end
