//
//  TCSAPIClientCustomization.h
//  TCSiCore
//
//  Created by a.v.kiselev on 16/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const TCSAPIClientMethodGET;
extern NSString *const TCSAPIClientMethodPOST;

extern NSString *const TCSKeyResponse;
extern NSString *const TCSKeyRequest;
extern NSString *const TCSKeyHandler;
extern NSString *const TCSKeyError;

extern NSString *const TCSNotificationResponseNeedsProcessing;


typedef void (^TCSCommonHandler)(BOOL success, NSError *error);


@protocol TCSAPIClientConfigurationProtocol <NSObject>

@required
- (NSString *)domainName;
- (NSString *)domainPath;

@optional
- (NSString *)sessionId; // TODO: get rid of session ID in this protocol

- (NSDictionary *)additionalCommonParameters;
- (BOOL)shouldKeepRequestCreationBlockInQueueCondition;

- (NSArray *)resultCodesSuccess;
- (NSArray *)resultCodesNeedProcessing;

- (NSString *)testConfirmationCodeRequestURL;
- (NSDictionary *)testConfirmationCodeRequestAdditionalParameters;

- (NSMutableSet *)pathsForMultipleSimultaniousOperations;

@end


@interface TCSAPIClientConfiguration : NSObject <TCSAPIClientConfigurationProtocol>

@property (nonatomic, strong) NSString *domainName;
@property (nonatomic, strong) NSString *domainPath;

@property (nonatomic, strong) NSDictionary *additionalCommonParameters;

@property (nonatomic, strong) NSArray *resultCodesSuccess;
@property (nonatomic, strong) NSArray *resultCodesNeedProcessing;

@property (nonatomic, strong) NSString *sessionId; // TODO: get rid of

@end


// Userinfo contains objects for "response", "handler" and "error" keys
//		"response" - NSDictionary contains server response with confirmation info (confirmation type,
//					 initialOperationTicket, etc.). This info is used to instantiate TCSConfirmationInfo object
//		"handler" - (void)(^)(BOOL success, id response, NSError *error) - block that should be performed
//					when confirmation is handled.
//						success - either confirmation was successful or not;
//						response - server response in case of successful confirmation passing;
//						error - error object, if something unexpected happend during confirmation
//		"error" - error that happened when requesting initial operation


// Example of typical method that handles this notification (code in Root View Controller)
//- (void)processResponse:(NSNotification *)notification
//{
//    NSDictionary *info = notification.userInfo;
//
//    void (^handler)(BOOL, id, NSError *) = info[TCSKeyHandler];	// Obtain data from notification
//    NSDictionary *response               = info[TCSKeyResponse];	//
//
//    NSString *resultCode = response[kResultCode];
//
//	if ([kResultCode_WAITING_CONFIRMATION isEqualToString:resultCode])	// Expecting to have WAITING_CONFIRMATION here. Otherwise assert(NO)
//	{
//		TCSConfirmationInfo *confirmationInfo = [[TCSConfirmationInfo alloc] initWithDictionary:response];	// Creating confirmationInfo object
//		confirmationInfo.completionBlock = ^(id responseObject, NSError *error) {							// Configuring it to interprate success as absence of errors
//			if (handler) { handler((error == nil), responseObject, error); }								//
//		};																									//
//
//		TCSPConfirmationVC *confirmVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ConfirmStoryboardID"]; // VC that handles all confirmations
//		confirmVC.confirmationInfo = confirmationInfo;
//
//		void (^presentConfirmationVC)() = ^																			// ConfirmationVC presenting block
//		{																											//
//			UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:confirmVC];		//
//			nc.navigationBar.translucent = NO;																		//
//			[self presentViewController:nc animated:YES completion:nil];											//
//		};																											//
//
//		UINavigationController *nc = (UINavigationController *)self.presentedViewController;	// Preparing VC's hierarchy to present ConfirmationVC
//		if ([nc isKindOfClass:[UINavigationController class]])									//
//		{																						//
//			TCSPConfirmationVC *vc = (TCSPConfirmationVC *)nc.topViewController;				//
//			if ([vc isKindOfClass:[TCSPConfirmationVC class]]) {								//
//				vc.confirmationInfo = confirmationInfo;											//
//			} else {																			//
//				[nc pushViewController:confirmVC animated:YES];									//
//			}																					//
//		}																						//
//		else																					//
//		{																						//
//			if (nc)	{ [self dismissViewControllerAnimated:YES									//
//											   completion:presentConfirmationVC]; }				//
//			else { presentConfirmationVC(); }													//
//		}																						//
//	}
//	else
//	{
//		NSAssert(0, @"Unhandled response: %@", response);
//		handler(NO, nil, info[TCSKeyError]);
//	}
//}
