//
//  TCSMTRequestProcessingManager.m
//  TCSMT
//
//  Created by Max Zhdanov on 30.07.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSResponseProcessingManager.h"
#import "TCSAPIClient.h"
#import "TCSAPIStrings.h"
#import "NSError+TCSAdditions.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"

NSString * const TCSNotificationShowConfirmationSMS = @"TCSNotificationShowConfirmationSMS";
NSString * const TCSNotificationShowConfirmation3DS = @"TCSNotificationShowConfirmation3DS";
NSString * const TCSNotificationShowConfirmationLOOP = @"TCSNotificationShowConfirmationLOOP";
NSString * const TCSNotificationShowUserBlockedScreen = @"TCSNotificationShowUserBlockedScreen";
NSString * const TCSNotificationDeviceLinkNeeded = @"TCSNotificationDeviceLinkNeeded";
NSString * const TCSNotificationInsufficientPrivileges = @"TCSNotificationInsufficientPrivileges";
NSString * const TCSNotificationMoneyAdditionRequired = @"TCSNotificationMoneyAdditionRequired";

NSString * const TCSCompletionBlockKey = @"TCSCompletionBlockKey";

@interface TCSResponseProcessingManager ()

@property (nonatomic, strong) NSString *currentConfirmationTicket;

@end

@implementation TCSResponseProcessingManager

@synthesize currentConfirmationTicket = _currentConfirmationTicket;

static TCSResponseProcessingManager * __sharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __sharedInstance = [[self alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:__sharedInstance selector:@selector(parseResponse:) name:TCSNotificationResponseNeedsProcessing object:nil];
    });
    return __sharedInstance;
}

- (void)parseResponse:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	id responseObject = userInfo[TCSKeyResponse];
	void (^handler)(BOOL, id, NSError *) = userInfo[TCSKeyHandler];
	TCSRequest * request = userInfo[TCSKeyRequest];
    
	[self parseJSONResponse:responseObject withRequest:request completionHandler:handler];
}

- (void)parseJSONResponse:(id)responseObject
			  withRequest:(TCSRequest *)request
		completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion
{
	NSString * resultCode  = [responseObject objectForKey:kResultCode];
	NSError * error = [NSError errorWithDomain:TCSErrorDomain code:TCSErrorCodeNone userInfo:responseObject];
	request.error = error;


    if ([resultCode isEqualToString:kResultCode_WAITING_CONFIRMATION])
    {
		[self processWaitingConfirmationResponseWithResponseObject:responseObject completionHandler:onCompletion];
    }
    else if ([resultCode isEqualToString:kResultCode_INSUFFICIENT_PRIVILEGES])
    {
		[self processInsufficientPrivilegesOrNotAuthenticatedWithResponseObject:responseObject
																	  error:error
														  completionHandler:onCompletion];
	}
    else if ([resultCode isEqualToString:kResultCode_USER_LOCKED])
    {
		[self processUserLockedResponseObject:responseObject
										error:error
							completionHandler:onCompletion];
    }
    else if ([resultCode isEqualToString:kResultCode_DEVICE_LINK_NEEDED] || [resultCode isEqualToString:kResultCode_NOT_AUTHENTICATED])
    {
		[self processDeviceLinkNeededWithResponseObject:responseObject
												  error:error
									  completionHandler:onCompletion];
	}
    else if ([resultCode isEqualToString:kResultCode_PIN_ATTEMPS_EXCEEDED])
    {
		[self processPinAttemptsExceededWithResponseObject:responseObject
													 error:error
										 completionHandler:onCompletion];
    }
    else if ([resultCode isEqualToString:kResultCode_OK])
	{
		[self processOkWithResponseObject:responseObject completionHandler:onCompletion];
	}
	else if ([resultCode isEqualToString:kResultCode_TOKEN_EXPIRED]) // когда токен соц сети заэкспайрился, блок вызывать нужно все равно
	{
		[self processPinAttemptsExceededWithResponseObject:responseObject
													 error:error
										 completionHandler:onCompletion];
    }
    else if([TCSResponseProcessingManager isPayloadContainsFieldForMoneyAddition:responseObject[TCSAPIKey_payload]])
    {
		[self processMoneyAdditionWithResponseObject:responseObject request:request completionHandler:onCompletion];

		return;
    }
	else
	{
		[self processOtherErrors:responseObject error:error completionHandler:onCompletion];
	}
}



#pragma mark -
#pragma mark - Response processing

- (void)processWaitingConfirmationResponseWithResponseObject:(id)responseObject
										   completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	NSString * initialOperation = [responseObject objectForKey:kInitialOperation];
	NSString * initialOperationTicket = [responseObject objectForKey:kOperationTicket];
	NSString *confirmationTypeString = [[responseObject objectForKey:kConfirmations] objectAtIndex:0];

	if ((_currentConfirmationTicket && [_currentConfirmationTicket isEqualToString:initialOperationTicket]) ||
		[confirmationTypeString isEqualToString:kConfirmationTypeEMAIL])
	{
		onCompletion(YES, responseObject, nil);
		return;
	}

    if (_currentConfirmationTicket == nil || (_currentConfirmationTicket && [_currentConfirmationTicket isEqualToString:initialOperationTicket] == NO)) {
        _currentConfirmationTicket = initialOperationTicket;
    }

	void (^successBlock)(MKNetworkOperation *) = ^(MKNetworkOperation *operation)
	{
		onCompletion(YES, operation.responseJSON, nil);
	};

	void (^failBlock)(MKNetworkOperation *, NSError *) = ^(MKNetworkOperation *operation, NSError *err)
	{
		onCompletion(NO, operation.responseJSON, err);
	};

	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys: initialOperation, kInitialOperation, initialOperationTicket, kInitialOperationTicket,confirmationTypeString, kConfirmationType, successBlock, kSuccessBlock, failBlock, kFailBlock, nil];

	if ([confirmationTypeString isEqualToString:kConfirmationType3DSecure])
	{
		NSString *urlString = [[[responseObject objectForKey:kConfirmationData] objectForKey:kConfirmationType3DSecure] objectForKey:TCSAPIKey_url];
		NSString *paRec = [[[responseObject objectForKey:kConfirmationData] objectForKey:kConfirmationType3DSecure] objectForKey:kRequestSecretCode];
		NSString *md = [[[responseObject objectForKey:kConfirmationData] objectForKey:kConfirmationType3DSecure] objectForKey:kMerchantData];

		params[TCSAPIKey_url] = urlString;
		params[kRequestSecretCode] = paRec;
		params[kMerchantData] = md;

		[[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationShowConfirmation3DS
															object:nil
														  userInfo:params];
	}
	else if ([confirmationTypeString isEqualToString:kConfirmationTypeLOOP])
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationShowConfirmationLOOP
															object:nil
														  userInfo:params];
	}
	else
	{
        NSValue *codeLength = [[[responseObject objectForKey:kConfirmationData] objectForKey:confirmationTypeString] objectForKey:kCodeLength];
        params[kCodeLength] = codeLength;
        [[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationShowConfirmationSMS
                                                            object:nil
                                                          userInfo:params];
    }
}

- (void)processInsufficientPrivilegesOrNotAuthenticatedWithResponseObject:(id)responseObject
																	error:(NSError *)error
														completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
    NSError *correctError = [NSError errorFromError:error withErrorMessage:@""];
    onCompletion(NO, responseObject, correctError);
	[[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationInsufficientPrivileges object:nil];
}

- (void)processUserLockedResponseObject:(id)responseObject
								  error:(NSError *)error
					  completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	[[NSNotificationCenter defaultCenter] postNotificationName:TCSNotificationShowUserBlockedScreen object:nil];
}

- (void)processDeviceLinkNeededWithResponseObject:(id)responseObject
											error:(NSError *)error
								completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	onCompletion(NO, responseObject, error);
	[[NSNotificationCenter defaultCenter]postNotificationName:TCSNotificationDeviceLinkNeeded object:nil];
}

- (void)processPinAttemptsExceededWithResponseObject:(id)responseObject
											   error:(NSError *)error
								   completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	onCompletion(NO, responseObject, error);
}

- (void)processTokenExpiredWithResponseObject:(id)responseObject completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	onCompletion(YES, responseObject, nil);
}

- (void)processMoneyAdditionWithResponseObject:(id)responseObject
									   request:(TCSRequest *)request
							 completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	NSDictionary * userInfo = @{
								TCSAPIKey_payload : responseObject[TCSAPIKey_payload],
								kRequest : request,
								TCSCompletionBlockKey : onCompletion
								};

	[[NSNotificationCenter defaultCenter]postNotificationName:TCSNotificationMoneyAdditionRequired object:nil userInfo:userInfo];
}

- (void)processOtherErrors:(id)responseObject
					 error:(NSError *)error
		 completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	onCompletion(NO, responseObject, error);
}

- (void)processOkWithResponseObject:(id)responseObject
				  completionHandler:(void (^)(BOOL, id, NSError *))onCompletion
{
	onCompletion(YES, responseObject, nil);
}




#pragma mark -
#pragma mark - Helpers

+ (BOOL)isPayloadContainsFieldForMoneyAddition:(NSDictionary *)payload
{
	NSString *reqSumString = [self reqSumStringWithPayload:payload];
	NSString *reqCurString = [self reqCurStringWithPayload:payload];

	if (reqSumString && reqCurString)
	{
		return YES;
	}

	return NO;
}

+ (NSString *)reqSumStringWithPayload:(NSDictionary *)payload
{
	NSString *reqSumString = [payload objectForKey:kReqSum];
	if (!reqSumString)
	{
		reqSumString = [payload objectForKey:kRegSum];
	}

	return reqSumString;
}

+ (NSString *)reqCurStringWithPayload:(NSDictionary *)payload
{
	NSString *reqCurString = [payload objectForKey:kReqCur];
	if (!reqCurString)
	{
		reqCurString = [payload objectForKey:kRegCur];
	}

	return reqCurString;
}


@end
