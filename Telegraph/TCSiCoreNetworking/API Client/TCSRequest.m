//
//  TCSP2PRequest.m
//  TCSP2P
//
//  Created by Alexey Voitenko on 14.02.14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSRequest.h"

@implementation TCSRequest
@synthesize path           = _path;
@synthesize requestKey     = _requestKey;
@synthesize parameters     = _parameters;
@synthesize responseObject = _responseObject;
@synthesize payload        = _payload;
@synthesize error          = _error;

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p> path=%@ requestKey=%@\nparameters=%@\nresponseObject=%@\n-----------\nerror=%@", [self class], self, _path, _requestKey, _parameters, _responseObject, _error];
}

@end
