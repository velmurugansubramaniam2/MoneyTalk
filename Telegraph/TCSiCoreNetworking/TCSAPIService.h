//
//  TCSAPIService.h
//  card2card
//
//  Created by Zabelin Konstantin on 13.02.15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+Factory.h"

@class TCSAPIClient;
@class MKNetworkOperation;


@protocol TCSAPIAuthorizationDelegate <NSObject>
- (void)acquireSessionIdWithCompletionBlock:(void (^)(NSString *session, NSError *error))handler;
@end



@interface TCSAPIService : NSObject

@property (atomic, weak) TCSAPIClient *apiClient; // default [TCSAPIClient sharedInstance]

@property (atomic, weak) id<TCSAPIAuthorizationDelegate> authDelegate; // If delegate is set, session will be added to request, otherwise - it won't

@property (nonatomic, strong) NSString	   *path;
@property (nonatomic, strong) NSDictionary *parameters;
@property (nonatomic, strong) NSString	   *method;		// default @"GET", you can use TCSAPIMethodPOST and TCSAPIMethodGET constants
@property (nonatomic, assign) BOOL addCommonParameters; // default YES

#ifdef DEBUG
@property (nonatomic, strong) id mockResult;
@property (nonatomic, strong) NSError *mockError;
#endif

- (MKNetworkOperation*)fetch:(void (^)(id result, NSError *error))complete;

@end
