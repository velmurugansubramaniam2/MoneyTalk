//
//  NSURL+Helpers.m
//  TCSiCore
//
//  Created by a.v.kiselev on 18/06/15.
//  Copyright (c) 2015 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "NSURL+Helpers.h"

@implementation NSURL (Helpers)

+ (NSURL *)resourceURLForName:(NSString *)resourceName
{
	NSString *path = [[ NSBundle mainBundle ] pathForResource:resourceName ofType:nil ];
	if( path == nil )
	{
		return nil;
	}
	else
	{
		return ( resourceName ) ? [ NSURL fileURLWithPath:path] : nil;
	}
}


@end
