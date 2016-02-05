//
//  TCSP2PDueDate.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMillisecondsTimestamp.h"
#import "TCSAPIDefinitions.h"

@implementation TCSMillisecondsTimestamp

@synthesize milliseconds = _milliseconds;
@dynamic seconds;
@dynamic date;

- (void)clearAllProperties
{
	_milliseconds = 0;
}

- (NSTimeInterval)milliseconds
{
	if (_milliseconds == 0)
	{
		_milliseconds = [[_dictionary objectForKey:kMilliseconds]doubleValue];
	}

	return _milliseconds;
}

- (NSTimeInterval)seconds
{
	return [self milliseconds]/1000.0f;
}

- (NSDate *)date
{
    return [NSDate dateWithTimeIntervalSince1970:self.seconds];
}

@end
