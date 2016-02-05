//
//  TCSNetworkLogger.h
//  TCSiCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSSingleton.h"

//#define TCS_NETWORK_LOGGING

@class NSArray, NSMutableArray, MKNetworkOperation, TCSRequestInfo;

@interface TCSNetworkLogger : TCSSingleton

@property (nonatomic, strong) NSMutableArray *requestsInfo; // TCSRequestInfo

- (void)logDoneOperation:(MKNetworkOperation *)operation;

- (TCSRequestInfo *)heaviestRequest;
- (NSArray *)requestsInfoSortedByDESC;

- (void)printTotalUsage;

@end
