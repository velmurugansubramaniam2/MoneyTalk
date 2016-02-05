//
//  TCSMTRequestProcessingManager.h
//  TCSMT
//
//  Created by Max Zhdanov on 30.07.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>


@class TCSRequest;

extern NSString * const TCSNotificationShowConfirmationSMS;
extern NSString * const TCSNotificationShowConfirmation3DS;
extern NSString * const TCSNotificationShowConfirmationLOOP;
extern NSString * const TCSNotificationShowUserBlockedScreen;
extern NSString * const TCSNotificationDeviceLinkNeeded;
extern NSString * const TCSNotificationInsufficientPrivileges;
extern NSString * const TCSNotificationMoneyAdditionRequired;

extern NSString * const TCSCompletionBlockKey;

@interface TCSResponseProcessingManager : NSObject

+ (instancetype)sharedInstance;

- (void)parseJSONResponse:(id)responseObject
			  withRequest:(TCSRequest *)request
		completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processWaitingConfirmationResponseWithResponseObject:(id)responseObject
										   completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processInsufficientPrivilegesOrNotAuthenticatedWithResponseObject:(id)responseObject
																error:(NSError *)error
													completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processUserLockedResponseObject:(id)responseObject
								  error:(NSError *)error
					  completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processDeviceLinkNeededWithResponseObject:(id)responseObject
											error:(NSError *)error
								completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processPinAttemptsExceededWithResponseObject:(id)responseObject
											   error:(NSError *)error
								   completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processTokenExpiredWithResponseObject:(id)responseObject
							completionHandler:(void (^)(BOOL, id, NSError *))onCompletion;

- (void)processMoneyAdditionWithResponseObject:(id)responseObject
									   request:(TCSRequest *)request
							 completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processOtherErrors:(id)responseObject
					 error:(NSError *)error
		 completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;

- (void)processOkWithResponseObject:(id)responseObject
				  completionHandler:(void (^)(BOOL success, id responseObject, NSError *error))onCompletion;




#pragma mark -
#pragma mark - Helpers

+ (BOOL)isPayloadContainsFieldForMoneyAddition:(NSDictionary *)payload;
+ (NSString *)reqSumStringWithPayload:(NSDictionary *)payload;
+ (NSString *)reqCurStringWithPayload:(NSDictionary *)payload;

@end
