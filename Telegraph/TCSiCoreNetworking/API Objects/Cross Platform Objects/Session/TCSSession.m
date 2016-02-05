//
//  TCSSession.m
//  TCSiCore
//
//  Created by a.v.kiselev on 14.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSSession.h"
#import "TCSAPIDefinitions.h"

@implementation TCSSession

@synthesize sessionId = _sessionId;
@synthesize sessionTimeout = _sessionTimeout;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	NSString *sessionid = [kSessionid lowercaseString];
	NSUInteger index = [[dictionary allKeys] indexOfObjectPassingTest:^BOOL(NSString *key, NSUInteger idx, BOOL *stop)
	{
		if ([[key lowercaseString] isEqualToString:sessionid])
		{
			*stop = YES;
			return *stop;
		}
		return NO;
	}];
	
	if (index == NSNotFound) { return nil; }

	self = [super initWithDictionary:dictionary];
	return self;
}

- (void)clearAllProperties
{
	_sessionId = nil;
	_sessionTimeout = nil;
}

- (NSString *)sessionId
{
	if (!_sessionId)
	{
        __block NSString *sessionid = nil;
        
        [_dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
        {
            if ([[key lowercaseString] isEqualToString:[kSessionid lowercaseString]])
            {
                sessionid = obj;
                *stop = YES;
            }
        }];
        
        _sessionId = sessionid;
	}

	return _sessionId;
}

- (NSNumber *)sessionTimeout
{
	if (!_sessionTimeout)
	{
//#warning TO DEBUG
//		_sessionTimeout = @(80);
		_sessionTimeout = [_dictionary objectForKey:kSessionTimeout];
	}

	return _sessionTimeout;  
}

- (NSTimeInterval)sessionTimoutInSeconds
{
	return [self.sessionTimeout unsignedLongValue];
}

- (BOOL)isNewUser
{
	NSNumber * isNewUser = [_dictionary objectForKey:kNewUser];
	if (isNewUser)
	{
		return [isNewUser boolValue];
	}
	
	return NO;
}

- (BOOL)isPinSet
{
	NSNumber * isNewUser = _dictionary[kPinSet];
	if (isNewUser)
	{
		return [isNewUser boolValue];
	}
	
	return NO;
}

@end
