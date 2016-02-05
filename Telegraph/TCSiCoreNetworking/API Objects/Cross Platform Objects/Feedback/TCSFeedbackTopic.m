//
//  TCSFeedbackTopic.m
//  TCSP2P
//
//  Created by Max Zhdanov on 21.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSFeedbackTopic.h"
#import "TCSFeedbackType.h"

@implementation TCSFeedbackTopic

@synthesize topicName = _topicName;
@synthesize topicTypes = _topicTypes;

- (void)clearAllProperties
{
	_topicName = nil;
    _topicTypes = nil;
}

- (NSString *)topicName
{
    if (!_topicName)
	{
		_topicName = [[_dictionary allKeys] objectAtIndex:0];
	}
    
	return _topicName;
}

- (NSArray *)topicTypes
{
    if (!_topicTypes)
    {
        NSMutableArray *_topicTypesArray = [NSMutableArray array];
        NSArray *keysArray = [_dictionary allKeys];
        
        for (NSString *key in keysArray)
        {
            TCSFeedbackType *oneType = [[TCSFeedbackType alloc] initWithDictionary : [NSDictionary dictionaryWithObject:[_dictionary valueForKey:key] forKey:key]];
            [_topicTypesArray addObject:oneType];
        }
        
        _topicTypes = [NSArray arrayWithArray:_topicTypesArray];
    }
    
    return _topicTypes;
}

@end
