//
//  TCSConstants.h
//  TCS
//
//  Created by a.v.kiselev on 25.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Logging & Assert

#ifdef DEBUG
	#define DEBUG_LOG
#endif

#ifdef ALog
#	undef ALog
#endif
#ifdef DLog
#	undef DLog
#endif

#ifdef DEBUG_LOG

#define DLog( s, ... )								NSLog( @"%@%s:(%d)> %@", [[self class] description], __FUNCTION__ , __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define ErrLog( s, ... )							NSLog( @"%@%s:(%d)> \n\n💥💥💥\nError: %@\n💥💥💥\n\n", [[self class] description], __FUNCTION__ , __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define ALog( s, ... )								\
    NSString * const __ALogErrorString__ = [NSString stringWithFormat:(s), ##__VA_ARGS__];\
    UIAlertView * const __ALogErrorAlert__ = [[UIAlertView alloc]initWithTitle:@"Error!" message:__ALogErrorString__ delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];\
    [__ALogErrorAlert__ show];\
													DLog(@"%@",[NSString stringWithFormat:(s), ##__VA_ARGS__]);
#else

#define ALog( s, ... )
#define DLog( s, ... )
#define ErrLog( s, ... )

#endif



///////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Localization

#define LOC(key)									NSLocalizedString(key, @"")



///////////////////////////////////////////////////////////////////
#pragma mark
#pragma mark SINGLETON_GCD

#define SINGLETON_GCD(classname)\
+ (id)sharedInstance\
{\
static dispatch_once_t pred = 0;\
__strong static id _sharedObject##classname = nil;\
dispatch_once(&pred,\
^{\
_sharedObject##classname = [[self alloc] init];\
});\
return _sharedObject##classname;\
}\


///////////////////////////////////////////////////////////////////

