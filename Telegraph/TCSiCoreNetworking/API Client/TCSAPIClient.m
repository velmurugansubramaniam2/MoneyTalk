//
//  TCSAPIClient.m
//  TCSiCore
//
//  Created by a.v.kiselev on 14.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSAPIClient.h"
#import "UIImage+CS_Extensions.h"
#import "NSDictionary+RequestEncoding.h"
#import "TCSNetworkLogger.h"
#import "UIDevice+Helpers.h"
#import "TCSAPIStrings.h"
#import "NSError+TCSAdditions.h"
#import "TCSMacroses.h"
#import "TCSAPIDefinitions.h"
#import "TCSAuthorizationStateManager.h"
#import "TCSSessionController.h"
#import "TCSResponseProcessingManager.h"

NSString *const TCSErrorDomainAPI = @"ru.tcsbank.api";

@interface TCSAPIClient ()



@end

@implementation TCSAPIClient

@synthesize engine = _engine;
@synthesize configuration = _configuration;

@synthesize arrayOfOperationsToEnqueue = _arrayOfOperationsToEnqueue;
@synthesize balanceAffectingAPIMethods = _balanceAffectingAPIMethods;
@synthesize shouldUseSSL = _shouldUseSSL;

@synthesize additionalCommonParameters = _additionalCommonParameters;
@synthesize resultCodesSuccess = _resultCodesSuccess;
@synthesize resultCodesNeedProcessing = _resultCodesNeedProcessing;
@synthesize sessionId = _sessionId;


- (NSString *)sessionId
{
    NSString *sessionId = [[TCSAuthorizationStateManager sharedInstance].sessionController sessionId];
    
    if (sessionId.length == 0)
    {
        _sessionId = [[TCSAuthorizationStateManager sharedInstance].sessionController temporarySessionId];
    }
    
    return _sessionId;
}


- (NSDictionary *)additionalCommonParameters
{
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    _additionalCommonParameters = @{
                                    kOrigin	 : @"mtalk,telegram",//kMtalk,
                                    kAppVersion : appVersionString,
                                    kDeviceId	 : [UIDevice deviceId],
                                    kPlatform   : @"ios"
                                    };
    return _additionalCommonParameters;
}


- (NSArray *)resultCodesSuccess
{
    if (!_resultCodesSuccess)
    {
        _resultCodesSuccess = @[kResultCode_OK,kResultCode_TOKEN_EXPIRED];
    }
    
    return _resultCodesSuccess;
}

- (NSArray *)resultCodesNeedProcessing
{
    if (!_resultCodesNeedProcessing)
    {
        _resultCodesNeedProcessing = @[kResultCode_WAITING_CONFIRMATION,
                                       kResultCode_INSUFFICIENT_PRIVILEGES,
                                       kResultCode_NOT_AUTHENTICATED,
                                       kResultCode_USER_LOCKED,
                                       kResultCode_PIN_ATTEMPS_EXCEEDED,
                                       kResultCode_DEVICE_LINK_NEEDED,
                                       kResultCode_INTERNAL_ERROR];
    }
    
    return _resultCodesNeedProcessing;
}

+ (NSString *)domainName
{
    return kDomainNameProd;
}

+ (NSString *)domainPath
{
    return kDomainPathV1;
}

- (NSString *)domainName
{
    return kDomainNameProd;
    
}

- (NSString *)domainPath
{
    return kDomainPathV1;
}

- (instancetype)init
{
    if (self = [super init])
    {
        _arrayOfOperationsToEnqueue = [NSMutableArray array];
        _shouldUseSSL = YES;
        
        __weak __typeof(self) weaksharedInstance = self;
        
        [TCSResponseProcessingManager sharedInstance];
        [[weaksharedInstance engine] setReachabilityChangedHandler:^(NetworkStatus networkStatus)
         {
             if (networkStatus == NotReachable)
             {
                 NSLog(@"Network status: not reachable");
             }
         }];
    }
    
    return self;
}



#pragma mark -
#pragma mark - Engine

- (MKNetworkEngine *)engine
{
	if (_engine) { return _engine; }
	if (!_configuration) { return nil; }
	
	NSMutableDictionary * headerFields = [NSMutableDictionary dictionary];
	[headerFields setObject:@"text/html,application/xhtml+xml,application/json,application/xml;q=0.9,*/*;q=0.8" forKey:@"Accept"];
	[headerFields setObject:@"gzip,deflate" forKey:@"Accept-Encoding"];
	[headerFields setObject:@"keep-alive" forKey:@"Connection"];
	NSBundle * mainBundle = [NSBundle mainBundle];

	NSString *userAgentString = [NSString stringWithFormat:@"%@/%@(%@)/%@/%@(%@)",
								 [UIDevice deviceModelName],
								 [UIDevice platform],
								 [UIDevice deviceOS],
								 [mainBundle infoDictionary][(NSString *)kCFBundleNameKey],
								 [mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
								 [mainBundle infoDictionary][(NSString *)kCFBundleVersionKey]];

	[headerFields setObject:userAgentString forKey:@"User-Agent"];

	_engine = [[MKNetworkEngine alloc] initWithHostName:[_configuration domainName]
												apiPath:[_configuration domainPath]
									 customHeaderFields:headerFields];



	[_engine useCache];

	return _engine;
}

- (void)setConfiguration:(id<TCSAPIClientConfigurationProtocol>)configuration
{
	if (_configuration == configuration) { return; }
	_configuration = configuration;
	
	_engine = nil;
}

#pragma mark -
#pragma mark - Creating Request Operation

- (MKNetworkOperation *)loadAndParseOperationWithPath:(NSString *)path
										   parameters:(NSDictionary *)body
										   httpMethod:(NSString *)method
								 additionalParameters:(NSDictionary *)additionalParameters // They would be added as GET params no matter what method is selected
											sessionId:(NSString *)sessionId
										 onCompletion:(TCSAPICompletion)completionBlock
{
	NSMutableDictionary * parametersToSpecifyInPath = [NSMutableDictionary dictionary];
	
	if ([additionalParameters count])
	{
		[parametersToSpecifyInPath addEntriesFromDictionary:additionalParameters];
	}
	
	if ([sessionId length] > 0)
	{
		parametersToSpecifyInPath[kSessionid] = sessionId;
		parametersToSpecifyInPath[kSessionId] = sessionId;
	}
	
	if (parametersToSpecifyInPath.allKeys.count > 0)
	{
		path = [NSString stringWithFormat:@"%@?%@", path, [parametersToSpecifyInPath urlEncodedKeyValueString]];
	}
	
	MKNetworkOperation * networkOperation = [self.engine operationWithPath:path params:body httpMethod:method ssl:self.shouldUseSSL];
	
	[networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
#ifdef DEBUG_LOG
		 [TCSAPIClient printLog:completedOperation];
#endif
		 TCSParseResponseHandler *parseResponseHandler = [[TCSParseResponseHandler alloc] initWithOperation:completedOperation
																							  parseDelegate:self
																						  onCompletionBlock:completionBlock];
		 [parseResponseHandler parseResponse];
	 }
							  errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
#ifdef DEBUG_LOG
		 [TCSAPIClient printLog:completedOperation];
#endif
		 completionBlock(completedOperation, nil, error);
	 }];
	
		//отменяем предыдущую операцию с полностью совпадающим адресом запроса
		//	DLog(@"HASH: %d",networkOperation.hash);
	[MKNetworkEngine cancelOperationsContainingURLString:networkOperation.readonlyRequest.URL.absoluteString];
	
	return networkOperation;
}


- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   onCompletion:(TCSAPICompletion)onCompletionBlock
{
	NSMutableDictionary *parametersToSpacifyInPath = [NSMutableDictionary dictionary];

	if (shouldInject)
	{
        [parametersToSpacifyInPath addEntriesFromDictionary:[self.configuration additionalCommonParameters]];
	}

	if (addSessionId)
	{
        NSString *sessionId = [[TCSAuthorizationStateManager sharedInstance].sessionController sessionId];
        
        if (sessionId.length == 0)
        {
            sessionId = [[TCSAuthorizationStateManager sharedInstance].sessionController temporarySessionId];
        }
		if ([sessionId length] > 0)
		{
			parametersToSpacifyInPath[kSessionid] = sessionId;
			parametersToSpacifyInPath[kSessionId] = sessionId;
		}
        else
        {
			DLog(@"\n\n\n***\nNO SESSION ID PROVIDED IN REQUEST FOR: %@!\n***\n\n\n", path);
		}
	}

	if (parametersToSpacifyInPath.allKeys.count > 0)
	{
		path = [NSString stringWithFormat:@"%@?%@", path, [parametersToSpacifyInPath urlEncodedKeyValueString]];
	}

	MKNetworkOperation *networkOperation = [self.engine operationWithPath:path params:body httpMethod:method ssl:self.shouldUseSSL];

	[networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
#ifdef DEBUG_LOG
		 [TCSAPIClient printLog:completedOperation];
#endif
		 TCSParseResponseHandler *parseResponseHandler = [[TCSParseResponseHandler alloc] initWithOperation:completedOperation
																							   parseDelegate:self
																						   onCompletionBlock:onCompletionBlock];

		 [parseResponseHandler parseResponse];

	 }
							  errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
#ifdef DEBUG_LOG
		 [TCSAPIClient printLog:completedOperation];
#endif
		 onCompletionBlock(completedOperation, nil, error);
	 }];

	//отменяем предыдущую операцию с полностью совпадающим адресом запроса
//	DLog(@"HASH: %d",networkOperation.hash);
	[MKNetworkEngine cancelOperationsContainingURLString:networkOperation.readonlyRequest.URL.absoluteString];

	return networkOperation;
}

- (MKNetworkOperation *)parsedOperationWithPath:(NSString *)path
										 params:(NSDictionary *)body
									 httpMethod:(NSString *)method
							parametersInjection:(BOOL)shouldInject
								   addSessionId:(BOOL)addSessionId
								   successBlock:(void (^)(MKNetworkOperation * operation, id responseObject))onSuccess
								   failureBlock:(void (^)(MKNetworkOperation * operation, NSError * error))onFail 
{

	NSMutableDictionary * parametersToSpacifyInPath = [NSMutableDictionary dictionary];

	if (shouldInject)
	{
		[parametersToSpacifyInPath addEntriesFromDictionary:[self.configuration additionalCommonParameters]];
	}

	if (addSessionId)
	{
		NSString * sessionId = [self.configuration sessionId];
		if (sessionId && sessionId.length > 0)
		{
			parametersToSpacifyInPath[kSessionid] = sessionId;
			parametersToSpacifyInPath[kSessionId] = sessionId;
		}else
		{
			DLog(@"\n\n\n***\nNO SESSION ID PROVIDED IN REQUEST FOR: %@!\n***\n\n\n", path);
		}
	}

	if (parametersToSpacifyInPath.allKeys.count > 0)
	{
		path = [NSString stringWithFormat:@"%@?%@", path, [parametersToSpacifyInPath urlEncodedKeyValueString]];
	}
	
	MKNetworkOperation * networkOperation = [self.engine operationWithPath:path params:body httpMethod:method ssl:self.shouldUseSSL];

	[networkOperation addCompletionHandler:^(MKNetworkOperation *completedOperation)
	 {
#ifdef DEBUG_LOG
		 [TCSAPIClient printLog:completedOperation];
#endif
		 TCSParseResponseHandler * parseResponseHandler = [[TCSParseResponseHandler alloc] initWithOperation:completedOperation
																							   parseDelegate:self
																								successBlock:onSuccess
																								failureBlock:onFail];


		 [parseResponseHandler parseResponse];

	 }
							  errorHandler:^(MKNetworkOperation *completedOperation, NSError *error)
	 {
#ifdef DEBUG_LOG
		 [TCSAPIClient printLog:completedOperation];
#endif
		 if (onFail)
		 {
			 onFail(completedOperation, error);
		 }
	 }];

	//отменяем предыдущую операцию с полностью совпадающим адресом запроса
	//	DLog(@"HASH: %d",networkOperation.hash);
	[MKNetworkEngine cancelOperationsContainingURLString:networkOperation.readonlyRequest.URL.absoluteString];

	return networkOperation;
}




#pragma mark -
#pragma mark - Performing Service Request

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
parametersInjection:(BOOL)shouldInject
addSessionId:(BOOL)addSessionId
	 success:(void (^)(MKNetworkOperation * completedOperation, id responseObject))success
	 failure:(void (^)(MKNetworkOperation * completedOperation, NSError *error))failure
{
	void (^enqueueOperation)() = ^
	{
		MKNetworkOperation *networkOperation = [self parsedOperationWithPath:path
																	  params:parameters
																  httpMethod:method
														 parametersInjection:shouldInject
																addSessionId:addSessionId
																onCompletion:^(MKNetworkOperation *operation, id responseObject, NSError *error) {
																	if (error) { if (failure) { failure(operation, error); } }
																	else	   { if (success) { success(operation, responseObject); }	}
																}];

		[self.engine enqueueOperation:networkOperation];
	};

	if (addSessionId && [self shouldKeepRequestCreationBlockInQueueCondition])
	{
		[_arrayOfOperationsToEnqueue addObject:[enqueueOperation copy]];
	}
		else
	{
		enqueueOperation();
	}
}

- (void)path:(NSString *)path
  withMethod:(NSString *)method
  parameters:(NSDictionary *)parameters
  parametersInjection:(BOOL)shouldInject
		 addSessionId:(BOOL)addSessionId
		 onCompletion:(void (^)(MKNetworkOperation * completedOperation, id responseObject, NSError * error))onCompletionBlock
{
	void (^enqueueOperation)() = ^
	{
		MKNetworkOperation *networkOperation = [self parsedOperationWithPath:path
																	   params:parameters
																   httpMethod:method
														  parametersInjection:shouldInject
																 addSessionId:addSessionId
																 onCompletion:onCompletionBlock];

		[self.engine enqueueOperation:networkOperation];
	};

	if (addSessionId && [self shouldKeepRequestCreationBlockInQueueCondition])
	{
		[_arrayOfOperationsToEnqueue addObject:[enqueueOperation copy]];
	}
		else
	{
		enqueueOperation();
	}
}


#pragma mark -
#pragma mark - Cancel request

+ (void)cancelOperationsContainingURLString:(NSString*)string
{
    BOOL shouldCheckForMatching = YES;
    NSArray * pathsToExclude = [[[TCSAPIClient sharedInstance].configuration pathsForMultipleSimultaniousOperations] allObjects];//[[[[self class]sharedInstance]pathsForMultipleSimultaniousOperations] allObjects];
    
    for (NSString * paths in pathsToExclude)
    {
        if ([string rangeOfString:paths].location != NSNotFound)
        {
            shouldCheckForMatching = NO;
            break;
        }
    }
    
    if (shouldCheckForMatching)
    {
        [MKNetworkEngine cancelOperationsMatchingBlock:^BOOL (MKNetworkOperation* op)
         {
             BOOL shouldCancel = [[op.readonlyRequest.URL absoluteString] rangeOfString:string].location != NSNotFound;
             
             if (shouldCancel)
             {
                 DLog(@"\n\n\n\nOperation with path %@ %@\n\n\n\n",[op.readonlyRequest.URL absoluteString], shouldCancel ? @"will be cancelled" : @"will continue executing");
             }
             
             return shouldCancel;
         }];
    }
}




#pragma mark -
#pragma mark - Grouped request

- (void)api_groupedRequests:(NSArray*)requestsAPIs
               addSessionId:(BOOL)addSessionId
                    success:(void (^)(NSArray *completedOperations))success
                    failure:(void (^)(NSArray *completedOperations, NSError *error))failure
{
    NSMutableArray * parametersArray = [NSMutableArray array];
    
    for (TCSRequest *request in requestsAPIs)
    {
        NSMutableDictionary * requestParameters = [NSMutableDictionary dictionary];
        [requestParameters setObject:request.requestKey forKey:kKey];
        [requestParameters setObject:request.path forKey:kOperation];
        
        if (request.parameters)
        {
            [requestParameters setObject:request.parameters forKey:kParams];
        }
        
        [parametersArray addObject:requestParameters];
    }
    
    NSError *error;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parametersArray options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        DLog(@"Error converting parameters array to data:%@",[TCSAPIClient messageFromError:error]);
    }
    
    NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //	NSString * path = [API_groupedRequests stringByAppendingFormat:@"?%@",[[self addSessionIdTo:[self parametersInjection:nil]] urlEncodedKeyValueString] ];
    
    NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:jsonString forKey:kRequestsData];
    
    Class selfClass = [self class];
    [self path:TCSAPIPath_grouped_requests
    withMethod:TCSAPIClientMethodGET
    parameters:parameters
parametersInjection:YES
  addSessionId:addSessionId
       success:^(MKNetworkOperation *completedOperation, id responseObject)
     {
         NSString * resultCode = [responseObject objectForKey:kResultCode];
         
         if ([resultCode isEqualToString:kResultCode_OK])
         {
             for (TCSRequest *request in requestsAPIs)
             {
                 NSString *requestKey = request.requestKey;
                 NSDictionary *response = responseObject[TCSAPIKey_payload][requestKey];
                 
                 if ([response[kResultCode] isEqualToString:kResultCode_OK])
                 {
                     request.responseObject = response;
                 }
                 else
                 {
                     request.error = [selfClass errorFromResponseObject:response];
                 }
             }
             
             if (success)
             {
                 success(requestsAPIs);
             }
         }
         else
         {
             if (failure)
             {
                 failure(requestsAPIs, [NSError errorWithDomain:resultCode ? TCSErrorDomainAPI : TCSErrorDomain code:TCSErrorCodeNone userInfo:responseObject]);
             }
         }
     }
       failure:^(MKNetworkOperation *completedOperation, NSError *operationError)
     {
         if (failure)
         {
             failure(requestsAPIs, operationError);
         }
     }];
}

- (void)api_groupedRequests:(NSArray*)requestsAPIs			//each object - TCSRequest
					success:(void (^)(NSArray *completedOperations))success
					failure:(void (^)(NSArray *completedOperations, NSError *error))failure
{
    [self api_groupedRequests:requestsAPIs
                 addSessionId:YES
                      success:success
                      failure:failure];
}

- (void)api_groupedRequests:(NSArray*)requestsAPIs
				 completion:(void (^)(NSArray *completedOperations, NSError *error))complete
{
    NSMutableArray * parametersArray = [NSMutableArray array];
    
    for (TCSRequest *request in requestsAPIs)
    {
        NSMutableDictionary * requestParameters = [NSMutableDictionary dictionary];
        [requestParameters setObject:request.requestKey forKey:kKey];
        [requestParameters setObject:request.path		forKey:kOperation];
        
        if (request.parameters)
        {
            [requestParameters setObject:request.parameters forKey:kParams];
        }
        
        [parametersArray addObject:requestParameters];
    }
    
	NSError *error;
	NSData * jsonData = [NSJSONSerialization dataWithJSONObject:parametersArray options:NSJSONWritingPrettyPrinted error:&error];
	if (error)
	{
		DLog(@"Error converting parameters array to data:%@",[TCSAPIClient messageFromError:error]);
	}
    
	NSString * jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    //	NSString * path = [API_groupedRequests stringByAppendingFormat:@"?%@",[[self addSessionIdTo:[self parametersInjection:nil]] urlEncodedKeyValueString] ];
    
	NSMutableDictionary * parameters = [NSMutableDictionary dictionaryWithObject:jsonString forKey:kRequestsData];
	
	Class selfClass = [self class];
	[self path:TCSAPIPath_grouped_requests
	withMethod:TCSAPIClientMethodGET
	parameters:parameters
	parametersInjection:YES
		   addSessionId:YES
		   onCompletion:^(MKNetworkOperation *completedOperation, id responseObject, NSError *operationError)
    {
        if ([[responseObject objectForKey:kResultCode] isEqualToString:kResultCode_OK])
        {
            for (TCSRequest *request in requestsAPIs)
            {
                NSString *requestKey = request.requestKey;
                NSDictionary *response = responseObject[TCSAPIKey_payload][requestKey];
                request.payload = response[TCSAPIKey_payload];
				
                if ([response[kResultCode] isEqualToString:kResultCode_OK])
                {
                    request.responseObject = response;
                }
                else
                {
                    request.error = [selfClass errorFromResponseObject:response];
                }
            }
        }
    
        if (complete)
        {
            complete(requestsAPIs, operationError);
        }
    }];
}



#pragma mark -
#pragma mark - Response parsing

- (void)parseJSONResponseFromRequest:(TCSRequest *)request
				   completionHandler:(void (^)(BOOL, NSError *))onCompletion
{
	NSAssert(onCompletion, @"Completion handler is mandatory");
	
	id responseObject = request.responseObject;
	if (![responseObject isKindOfClass:[NSDictionary class]])
	{
		NSError *error = [NSError errorWithDomain:TCSErrorDomainAPI
											 code:TCSResponseCodeEmptyResponse
										 userInfo:nil];
		onCompletion(NO, error);
		return;
	}
	NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"Expecting that response is a kind of NSDictionary, responseObject: %@", responseObject);
	
	NSString *resultCode = [responseObject valueForKey:kResultCode];
	NSError  *error		 = [[self class] errorFromResponseObject:responseObject];
	
    request.error   = error;
    request.payload = responseObject[TCSAPIKey_payload];
	
	if ([[self.configuration resultCodesSuccess] containsObject:resultCode])
	{
		onCompletion(YES, nil);
	}
	else if ([[self.configuration resultCodesNeedProcessing] containsObject:resultCode])
	{
		void (^handler)(BOOL, id, NSError *) = ^(BOOL success, id handlerResponseObject, NSError *handlerError)
		{
			request.responseObject = handlerResponseObject;
			request.error = handlerError;
			onCompletion(success, handlerError);
		};
		
		NSDictionary *userInfo = @{ TCSKeyResponse : responseObject,
									TCSKeyHandler  : handler,
									TCSKeyError	   : error ,
									TCSKeyRequest  : request};
		
		NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
		[notificationCenter postNotificationName:TCSNotificationResponseNeedsProcessing
										  object:self
										userInfo:userInfo];
	}
	else
	{
		onCompletion(NO, error);
	}
}




#pragma mark -
#pragma mark - Requests Queueing

- (BOOL)shouldKeepRequestCreationBlockInQueueCondition
{
	return NO;
}

- (void)performBlocksInQueue
{
	for (void (^ enqueueOperationBlock)() in _arrayOfOperationsToEnqueue)
	{
		enqueueOperationBlock();
	}

	[_arrayOfOperationsToEnqueue removeAllObjects];
}




#pragma mark -
#pragma mark - Helpers

+ (NSString *)messageFromError:(NSError *)error
{
    NSDictionary * const userInfo = [error userInfo];
	NSString * errorString = userInfo[NSLocalizedDescriptionKey];

    if (errorString == nil) {
        errorString = userInfo[kErrorMessage];
    }

    if (errorString == nil)
	{
		errorString = LOC(@"error.connectionError");
	}

	return errorString;
}

+ (void)printLog:(MKNetworkOperation *)operation
{
	dispatch_barrier_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{

		DLog(@"\n**************************************************\n");
		DLog(@"\nOperation:\n%@",[operation description]);
		DLog(@"\n**************************************************\n");

		if ([operation isCachedResponse])
		{
			DLog(@"\n**************************************************\n");
			DLog(@"\n***********Запрос из кэша*************************\n");
			DLog(@"\n**************************************************\n");
		}

	});
}

+ (NSError *)errorFromResponseObject:(id)object
{
	if (!object) {
		return [NSError errorWithDomain:TCSErrorDomainAPI
								   code:TCSResponseCodeEmptyResponse
							   userInfo:nil];
	}
	
	if (![object isKindOfClass:[NSDictionary class]]) { return nil; }
	
	NSDictionary *response = (NSDictionary *)object;
	
	static NSDictionary *resultCodeTranslator = nil;
	
	if (!resultCodeTranslator)
	{
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			resultCodeTranslator = @{ kResultCode_WAITING_CONFIRMATION		  : @(TCSResponseCode_WAITING_CONFIRMATION),
									  kResultCode_OK						  : @(TCSResponseCodeOK),
									  kResultCode_DEVICE_LINK_NEEDED		  :	@(TCSResponseCode_DEVICE_LINK_NEEDED),
									  kResultCode_NOT_AUTHENTICATED			  : @(TCSResponseCode_NOT_AUTHENTICATED),
									  kResultCode_INSUFFICIENT_PRIVILEGES	  : @(TCSResponseCode_INSUFFICIENT_PRIVILEGES),
									  kResultCode_USER_LOCKED				  : @(TCSResponseCode_USER_LOCKED),
									  kResultCode_PIN_ATTEMPS_EXCEEDED		  : @(TCSResponseCode_PIN_ATTEMPTS_EXCEEDED),
									  kResultCode_WRONG_CONFIRMATION_CODE	  : @(TCSResponseCode_WRONG_CONFIRMATION_CODE),
									  kResultCode_CONFIRMATION_FAILED		  : @(TCSResponseCode_CONFIRMATION_FAILED),
									  kResultCode_TOKEN_EXPIRED				  : @(TCSResponseCode_TOKEN_EXPIRED),
									  kResultCode_INTERNAL_ERROR			  :	@(TCSResponseCode_INTERNAL_ERROR),
									  kResultCode_INVALID_REQUEST_DATA		  : @(TCSResponseCode_INVALID_REQUEST_DATA),
									  kResultCode_OPERATION_REJECTED		  : @(TCSResponseCode_OPERATION_REJECTED),
									  kResultCode_REQUEST_RATE_LIMIT_EXCEEDED : @(TCSResponseCode_REQUEST_RATE_LIMIT_EXCEEDED),
									  kResultCode_WRONG_PIN_CODE			  : @(TCSResponseCode_WRONG_PIN_CODE),
									  kResultCode_PIN_IS_NOT_SET			  : @(TCSResponseCode_PIN_IS_NOT_SET),
									  kResultCode_AUTHENTICATION_FAILED		 : @(TCSResponseCode_AUTHENTICATION_FAILED),
								      kResultCode_RESEND_FAILED				 : @(TCSResponseCode_RESEND_FAILED)
									};
		});
	}
	
	NSNumber *resultCodeNum = resultCodeTranslator[response[kResultCode]];
//	NSAssert(resultCodeNum, @"Unknown resultCode");
	
	NSInteger resultCode = resultCodeNum ? [resultCodeNum integerValue] : TCSResponseCodeError;
	if (resultCode == TCSResponseCodeOK) { return nil; } // Unknown result codes will be handled as exceptions in Debug mode and as "no error" in production
	
	NSError *error = [NSError errorWithDomain:TCSErrorDomainAPI
										 code:resultCode
									 userInfo:object];
	return error;
}


#pragma mark -
#pragma mark - Network Logger

#ifdef TCS_NETWORK_LOGGING

- (void)enqueueOperation:(MKNetworkOperation *)operation forceReload:(BOOL)forceReload
{
    void (^operationChangeStateCopy)(MKNetworkOperationState) = [operation.operationStateChangedHandler copy];
    
    __weak MKNetworkOperation *weakOperation = operation;
    
    [operation setOperationStateChangedHandler:^(MKNetworkOperationState state)
     {
         if (state == MKNetworkOperationStateFinished)
         {
             [[TCSNetworkLogger sharedInstance] logDoneOperation:weakOperation];
         }
         
         if (operationChangeStateCopy)
         {
             operationChangeStateCopy(state);
         }
         
     }];
    
    [super enqueueOperation:operation forceReload:forceReload];
}

#endif

@end
