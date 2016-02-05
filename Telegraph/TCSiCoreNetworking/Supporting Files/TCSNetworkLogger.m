//
//  TCSNetworkLogger.m
//  TCSiCore
//
//  Created by Gleb Ustimenko on 04.08.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSNetworkLogger.h"

#import <Foundation/Foundation.h>
#import "TCSRequestInfo.h"
#import "MKNetworkOperation.h"

@implementation TCSNetworkLogger

@synthesize requestsInfo = _requestsInfo;

- (NSMutableArray *)requestsInfo
{
    if (!_requestsInfo)
    {
        _requestsInfo = [NSMutableArray new];
    }
    
    return _requestsInfo;
}

- (void)logDoneOperation:(MKNetworkOperation *)operation
{
    if (operation.isCachedResponse)
    {
        return;
    }
    
    TCSRequestInfo *requestInfo = [TCSRequestInfo  new];
    
    requestInfo.url = operation.url;
    
    SEL selector = NSSelectorFromString(@"downloadedDataSize");
    NSUInteger (*implFunction)(id, SEL) = (void *)[operation methodForSelector:selector];
    NSUInteger dataSize = implFunction(operation, selector);
    
    requestInfo.bytes = @(dataSize);
    
    [self.requestsInfo addObject:requestInfo];
}

- (TCSRequestInfo *)heaviestRequest
{
    NSArray *heaviestRequest = [self.requestsInfo sortedArrayUsingComparator:^NSComparisonResult(TCSRequestInfo *obj1, TCSRequestInfo *obj2)
    {
        return [obj1.bytes compare:obj2.bytes];
    }];
    
    return [heaviestRequest lastObject];
}

- (void)printTotalUsage
{
#ifdef DEBUG_LOG
    NSNumber *totalUsage = [self.requestsInfo valueForKeyPath:@"@sum.bytes"];
    DLog(@"%@", [NSByteCountFormatter stringFromByteCount:[totalUsage integerValue] countStyle:NSByteCountFormatterCountStyleFile]);
#endif
}

- (NSArray *)requestsInfoSortedByDESC
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bytes" ascending:NO];
    
    NSArray *requestsInfoSortedByDESC = [self.requestsInfo sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return requestsInfoSortedByDESC;
}

@end
