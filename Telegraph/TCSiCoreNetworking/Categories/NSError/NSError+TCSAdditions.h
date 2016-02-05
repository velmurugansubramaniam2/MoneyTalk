//
//  NSError+TCSAdditions.h
//  TCSiCore
//
//  Created by a.v.kiselev on 18/09/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TCSErrorDomain;

typedef NS_ENUM(NSInteger, TCSErrorCode)
{
	TCSErrorCodeNone            = 0,
	TCSErrorCodeInvalidArgument = 1,
	TCSErrorCodeEmptyResult     = 2,
	TCSErrorCodeCanceledByUser  = 3,
    TCSErrorCodeInvalidResult   = 4
};


@interface NSError (TCSAdditions)

+ (NSError *)errorFromError:(NSError *)error withErrorMessage:(NSString *)errorMessage;

- (NSString *)errorMessage;
- (NSString *)trackingId;
- (NSString *)resultCode;
- (NSDictionary *)payload;

@property (nonatomic, readonly, getter=isCancellation) BOOL cancellation;

@end
