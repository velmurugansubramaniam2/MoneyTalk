//
//  TCSFeedbackTopicsList.m
//  TCSP2P
//
//  Created by Max Zhdanov on 21.08.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSFeedbackTopicsList.h"
#import "TCSFeedbackTopic.h"
#import "TCSAPIStrings.h"


@implementation TCSFeedbackTopicsList

@synthesize feedbackTopicsList = _feedbackTopicsList;

- (void)clearAllProperties
{
	_feedbackTopicsList = nil;
}

- (NSArray *)feedbackTopicsList
{
    if (!_feedbackTopicsList)
    {
        NSMutableArray *topics = [NSMutableArray array];
        NSArray *keysArray = [[_dictionary objectForKey:TCSAPIKey_payload] allKeys];
        
        for (NSString *key in keysArray)
        {
            TCSFeedbackTopic *oneTopic = [[TCSFeedbackTopic alloc] initWithDictionary:[[_dictionary objectForKey:TCSAPIKey_payload] objectForKey:key]];
            [topics addObject:oneTopic];
        }
        
        _feedbackTopicsList = [NSArray arrayWithArray:topics];
    }
    
    return _feedbackTopicsList;
}

@end
