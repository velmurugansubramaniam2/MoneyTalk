//
//  NSError+TCSAdditions.m
//  TCSiCore
//
//  Created by a.v.kiselev on 18/09/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSError+TCSAdditions.h"
#import "TCSAPIDefinitions.h"
#import "TCSAPIStrings.h"



NSString *const TCSErrorDomain = @"ru.tcsbank.application";


@implementation NSError (TCSAdditions)

+ (NSError *)errorFromError:(NSError *)error withErrorMessage:(NSString *)errorMessage
{
	NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithDictionary:[error userInfo]];
	[userInfo setObject:errorMessage forKey:TCSAPIKey_errorMessage];
	
	return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

- (NSString *)errorMessage
{
	NSString *errorMessage = self.userInfo[TCSAPIKey_errorMessage];

	if (!errorMessage)
	{
		errorMessage = self.localizedDescription;
	}

	return errorMessage;
}

- (NSString *)trackingId
{
	return self.userInfo[TCSAPIKey_trackingId];
}

- (NSString *)resultCode
{
	return self.userInfo[TCSAPIKey_resultCode];
}

- (NSDictionary *)payload
{
	return self.userInfo[TCSAPIKey_payload];
}

- (BOOL)isCancellation
{
	return ([TCSErrorDomain isEqualToString:self.domain] && self.code == TCSErrorCodeCanceledByUser);
}

@end
