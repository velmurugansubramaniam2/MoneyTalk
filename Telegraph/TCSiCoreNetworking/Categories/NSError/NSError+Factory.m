//
//  NSError+Factory.m
//  card2card
//
//  Created by Zabelin Konstantin on 13.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSError+Factory.h"
#import "NSError+TCSAdditions.h"
#import "TCSAPIDefinitions.h"
#import "TCSAPIStrings.h"



@implementation NSError (Factory)

+ (NSError *)errorWithCode:(NSInteger)code {
	return [self errorWithCode:code message:nil];
}

+ (NSError *)errorWithCode:(NSInteger)code message:(NSString *)message
{
	return [NSError errorWithDomain:TCSErrorDomain
							   code:code
						   userInfo:[message length] ? @{ TCSAPIKey_errorMessage : message } : nil];
}

@end
