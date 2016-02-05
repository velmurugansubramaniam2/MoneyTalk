//
//  TCSAPIService.m
//  card2card
//
//  Created by Zabelin Konstantin on 13.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//


#import "TCSAPIService.h"
#import "TCSiCoreNetworking.h"
#import "NSError+TCSNetworking.h"
//#import <KiteJSONValidator/KiteJSONValidator.h>

#import "TCSAPIClient.h"
#import "TCSAPIStrings.h"



@implementation TCSAPIService

@synthesize authDelegate = _authDelegate, apiClient = _apiClient;
@synthesize path = _path, parameters = _parameters, method = _method, addCommonParameters = _addCommonParameters;
#ifdef DEBUG
@synthesize mockResult = _mockResult, mockError = _mockError;
#endif

- (instancetype)init
{
	self = [super init];
	if (!self) { return nil; }

    _apiClient           = [TCSAPIClient sharedInstance];
    _addCommonParameters = YES;
    _method              = @"GET";
	
	return self;
}

- (MKNetworkOperation*)fetch:(void (^)(id result, NSError *error))complete
{
    __block MKNetworkOperation *operation;

	NSString *path = _path ?: @"";
	void (^internalComplete)(id, NSError *) = ^(id result, NSError *error)
	{
        if (complete) { complete(result, error); }
	};
	
#ifdef DEBUG
	DLog(@"Fetching service: %@", _path ?: @"");
	
    id mockResult      = _mockResult;
    NSError *mockError = _mockError;
	if (mockResult || mockError)
	{
		dispatch_async(dispatch_get_main_queue(), ^{ internalComplete(mockResult, mockError); });
		return operation;
	}
#endif
	
	TCSAPIClient *apiClient = _apiClient;
	
    NSDictionary *parameters           = _parameters;
    NSString	 *method               = _method;
	NSDictionary *additionalParameters = _addCommonParameters ? apiClient.configuration.additionalCommonParameters : nil;
		
	void (^createAndEnqueueOperation)(NSString *, NSError *) = ^(NSString *sessionId, NSError *sessionError)
	{
		if (!apiClient.engine)
		{
			internalComplete(nil, [NSError errorWithCode:TCSErrorCodeEmptyResult]);
			return;
		}
		
		if (sessionError)
		{
			internalComplete(nil, sessionError);
			return;
		}

		TCSAPICompletion validatedCompletion = ^(MKNetworkOperation *finalOperation, id responseObject, NSError *error)
		{
			if (responseObject && !error)
			{
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
				{
                    BOOL resultIsValid = YES; //apiClient.validator ? [self validateResult:responseObject forUrl:[NSURL URLWithString:finalOperation.url]] : YES;

                    NSError * const error = resultIsValid ? nil : [NSError errorWithDomain:TCSErrorDomainAPI code:TCSErrorCodeInvalidResult userInfo:@{TCSAPIKey_errorMessage : responseObject}];

                    if (error) {
                        [error logToAPI];
                    }

                    dispatch_async(dispatch_get_main_queue(), ^{
                        internalComplete(responseObject, error);
                    });
                    
				});
			}
			else {
				internalComplete(responseObject, error);
			}
		};
		
		operation = [apiClient loadAndParseOperationWithPath:path
												  parameters:parameters
												  httpMethod:method
										additionalParameters:additionalParameters
												   sessionId:sessionId
												onCompletion:validatedCompletion];
		[apiClient.engine enqueueOperation:operation];
	};
	
	id <TCSAPIAuthorizationDelegate> authDelegate = _authDelegate;
	
	if (!authDelegate) { createAndEnqueueOperation(nil, nil); }
	else
	{
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[authDelegate acquireSessionIdWithCompletionBlock:createAndEnqueueOperation];
		});
	};

    return operation;
}

- (BOOL)validateResult:(id)result forUrl:(NSURL *)url
{
    BOOL isValid = YES;
    NSString * const pathComponent = [url lastPathComponent];


    TCSAPIClient * const client = self.apiClient;
//    NSDictionary * const schema = [client schemaForIdentifier:pathComponent];

		// TODO: uncomment before testing
//    NSAssert1(schema, @"No schema found in the application bundle for service: %@", pathComponent);

//    isValid = client && schema ? [client.validator validateJSONInstance:result withSchema:schema] : YES;

    return isValid;
}

@end
