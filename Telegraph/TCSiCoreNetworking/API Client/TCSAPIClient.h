//
//  TCSAPIClient.h
//  TCSiCore
//
//  Created by a.v.kiselev on 14.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "MKNetworkKit.h"
#import "TCSAPIDefinitions.h"
#import "TCSAPIObjects.h"
#import "TCSRequest.h"

#import "TCSParseResponseHandler.h"
#import "TCSAPIClientConfiguration.h"
#import "TCSSingleton.h"


extern NSString *const TCSErrorDomainAPI;

typedef NS_ENUM(NSInteger, TCSResponseCode)
{
	TCSResponseCodeEmptyResponse				= -1,
	TCSResponseCodeOK                           = 0,
	TCSResponseCodeServerError                  = 1,
	TCSResponseCodeError                        = 100,
	TCSResponseCode_WAITING_CONFIRMATION        = 101,
	TCSResponseCode_INSUFFICIENT_PRIVILEGES     = 102,
	TCSResponseCode_DEVICE_LINK_NEEDED          = 103,
	TCSResponseCode_OPERATION_REJECTED          = 104,
	TCSResponseCode_CONFIRMATION_FAILED         = 105,
	TCSResponseCode_NOT_AUTHENTICATED           = 106,
	TCSResponseCode_USER_LOCKED                 = 107,
	TCSResponseCode_PIN_ATTEMPTS_EXCEEDED       = 108,
	TCSResponseCode_WRONG_CONFIRMATION_CODE     = 109,
	TCSResponseCode_TOKEN_EXPIRED               = 110,
	TCSResponseCode_INTERNAL_ERROR              = 111,
	TCSResponseCode_INVALID_REQUEST_DATA        = 112,
	TCSResponseCode_REQUEST_RATE_LIMIT_EXCEEDED = 113,
	TCSResponseCode_WRONG_PIN_CODE				= 114,
	TCSResponseCode_PIN_IS_NOT_SET				= 115,
	TCSResponseCode_AUTHENTICATION_FAILED		= 116,
	TCSResponseCode_RESEND_FAILED				= 117
};

typedef void(^TCSAPICompletion)(MKNetworkOperation * operation, id responseObject, NSError * error);




@interface TCSAPIClient : TCSSingleton <TCSParseResponseHandlerDelegate, TCSAPIClientConfigurationProtocol>

@property (nonatomic, strong) MKNetworkEngine *engine;
@property (nonatomic, copy) id<TCSAPIClientConfigurationProtocol> configuration;

@property (nonatomic, readonly) NSMutableArray * arrayOfOperationsToEnqueue;

@property (nonatomic, strong) NSMutableArray *balanceAffectingAPIMethods;
@property (nonatomic, assign) BOOL shouldUseSSL;

@property (nonatomic, strong) NSDictionary *additionalCommonParameters;
@property (nonatomic, strong) NSArray *resultCodesSuccess;
@property (nonatomic, readonly) NSArray *resultCodesNeedProcessing;
@property (nonatomic, strong) NSString *sessionId;


#pragma mark -
#pragma mark - Requests Queueing

/**
 Метод, внутри которого должны определяться критерии добавления блока создания запроса в очередь (например, если пользователь не авторизован(или протухла сессия), но успел отправить запрос требующий валидной сессии).
 По умолчанию метод возвращает NO.
 */
- (BOOL)shouldKeepRequestCreationBlockInQueueCondition;

/**
 Выполняет все блоки, находящиеся в очереди.
 */
- (void)performBlocksInQueue;




#pragma mark -
#pragma mark - Create operation

- (MKNetworkOperation *)loadAndParseOperationWithPath:(NSString *)path
										   parameters:(NSDictionary *)body
										   httpMethod:(NSString *)method
								 additionalParameters:(NSDictionary *)additionalParameters // They would be added as GET params no matter what method is selected
											sessionId:(NSString *)sessionId
										 onCompletion:(TCSAPICompletion)completionBlock;

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   onCompletion:(TCSAPICompletion)onCompletionBlock;


/** Return the user name or userid that should be send along each crash report
 @deprecated Please use `parsedOperationWithPath:(NSString *)path
 params:(NSDictionary *)body
 httpMethod:(NSString *)method
 parametersInjection:(BOOL)shouldInject
 addSessionId:(BOOL)addSessionId
 onCompletion:(void (^)(MKNetworkOperation * operation, id responseObject, NSError * error))onCompletionBlock` instead
 */

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   successBlock:(void (^)(MKNetworkOperation * operation, id responseObject))onSuccess
								   failureBlock:(void (^)(MKNetworkOperation * operation, NSError * error))onFail DEPRECATED_ATTRIBUTE;




#pragma mark -
#pragma mark - Create request (automatically enqueue operation)

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
parametersInjection:(BOOL)shouldInject
addSessionId:(BOOL)addSessionId
	 success:(void (^)(MKNetworkOperation * completedOperation, id responseObject))success
	 failure:(void (^)(MKNetworkOperation * completedOperation, NSError *error))failure;

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
  parametersInjection:(BOOL)shouldInject
		 addSessionId:(BOOL)addSessionId
		 onCompletion:(void (^)(MKNetworkOperation * completedOperation, id responseObject, NSError * error))onCompletionBlock;




#pragma mark -
#pragma mark - Grouped request

- (void)api_groupedRequests:(NSArray*)requestsAPIs			//each object - TCSRequest
					success:(void (^)(NSArray *completedOperations))success
					failure:(void (^)(NSArray *completedOperations, NSError *error))failure;

- (void)api_groupedRequests:(NSArray*)requestsAPIs
               addSessionId:(BOOL)addSessionId
                    success:(void (^)(NSArray *completedOperations))success
                    failure:(void (^)(NSArray *completedOperations, NSError *error))failure;



- (void)api_groupedRequests:(NSArray*)requestsAPIs          //each object - TCSRequest
				 completion:(void (^)(NSArray *completedOperations, NSError *error))complete;




#pragma mark -
#pragma mark - Helpers

+ (NSString *)messageFromError:(NSError *)error;
+ (void)printLog:(MKNetworkOperation *)operation;

@end
