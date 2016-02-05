//
//  TCSCompatibility.m
//  TCSP2P
//
//  Created by a.v.kiselev on 18.09.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSCompatibility.h"
#import "TCSAPIStrings.h"
#import "TCSAPIDefinitions.h"

@implementation TCSCompatibility


- (void)clearAllProperties
{

}

- (float)leastCompatibleVersion
{
	return [_dictionary[kLeastCompatibleVersion] floatValue];
}
- (float)newVersion
{
	return [_dictionary[kNewVersion] floatValue];
}

- (NSTimeInterval)newVersionDate
{
	return [_dictionary[kNewVersionDate] doubleValue];
}

- (NSString*)releaseNotes
{
	return _dictionary[kReleaseNotes];
}

- (NSString*)releaseNotesTitle
{
    return _dictionary[kReleaseNotesTitle];
}

- (NSURL *)url
{
    return [NSURL URLWithString:_dictionary[TCSAPIKey_url]];
}

@end
