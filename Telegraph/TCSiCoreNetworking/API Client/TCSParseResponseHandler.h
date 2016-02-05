//
//  TCSParseResponseHandler.h
//  TCSiCore
//
//  Created by a.v.kiselev on 14.03.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKNetworkOperation.h"
#import "TCSRequest.h"

extern NSString * const TCSNotificationBalanceAffected;

@class TCSError;

@protocol TCSParseResponseHandlerDelegate <NSObject>
@optional
- (void)parseJSONResponseFromRequest:(TCSRequest *)request
				   completionHandler:(void (^)(BOOL success, NSError *error))complete;
- (NSArray *)balanceAffectingAPIMethods;

@end

@interface TCSParseResponseHandler : NSObject

@property (nonatomic, weak) id<TCSParseResponseHandlerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray * requestsQueue;
@property (nonatomic, strong) NSArray * requestsArray;
@property (nonatomic, readonly, strong) MKNetworkOperation * operation;

@property (nonatomic, copy) void(^onCompletion)(MKNetworkOperation * operation, id responseObject, NSError *error);
@property (nonatomic, copy) void(^onSuccess)(MKNetworkOperation * operation, id responseObject);
@property (nonatomic, copy) void(^onFailure)(MKNetworkOperation * operation, NSError * error);

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<TCSParseResponseHandlerDelegate>)delegate
		   successBlock:(void (^)(MKNetworkOperation * operation, id responseObject))onSuccess
		   failureBlock:(void (^)(MKNetworkOperation * operation, NSError * error))onFailure;

- (id)initWithOperation:(MKNetworkOperation *)operation
		  parseDelegate:(id<TCSParseResponseHandlerDelegate>)delegate
	  onCompletionBlock:(void (^)(MKNetworkOperation * operation, id responseObject, NSError * error))onCompletionBlock;

- (void)parseResponse;

@end
