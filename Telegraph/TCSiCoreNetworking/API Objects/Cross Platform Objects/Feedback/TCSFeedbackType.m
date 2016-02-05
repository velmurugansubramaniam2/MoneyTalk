//
//  TCSFeedbackType.m
//  TCSP2P
//
//  Created by Max Zhdanov on 21.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSFeedbackType.h"

@implementation TCSFeedbackType

@synthesize type = _type;
@synthesize subject = _subject;

- (void)clearAllProperties
{
	_type = nil;
    _subject = nil;
}

- (NSString *)subject
{
    if (!_subject)
	{
		_subject = [[_dictionary allKeys] objectAtIndex:0];
	}
    
	return _subject;
}

- (NSString *)type
{
    if (!_type) {
        _type = [_dictionary objectForKey:[self subject]];
    }
    
    return _type;
}

@end
