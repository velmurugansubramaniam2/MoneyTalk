//
//  TCSP2PBaseObject.m
//  TCSP2P
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSBaseObject.h"

@implementation TCSBaseObject
@synthesize dictionary = _dictionary;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	if (!dictionary) { return nil; }

	self = [super init];
	if (!self) { return nil; }

	_dictionary = dictionary;
	return self;
}

- (void)setDictionary:(NSDictionary *)dictionary
{
	[self clearAllProperties];
	_dictionary = dictionary;
}

- (void)clearAllProperties
{
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wselector"
//	ALog(@"%@ method not implemented in class %@",	NSStringFromSelector(_cmd), NSStringFromClass([self class]));
//#pragma clang diagnostic pop
}

-(BOOL)isEqual:(id)object
{
    if (![object isMemberOfClass:[self class]]) { return NO; }

	TCSBaseObject *objectAsBaseObject = (TCSBaseObject*)object;
	return [self.dictionary isEqualToDictionary:objectAsBaseObject.dictionary];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"%@ object with data:\n%@", [self class], _dictionary];
}

@end
