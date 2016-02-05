//
//  TCSDataController.m
//  TCSMT
//
//  Created by a.v.kiselev on 25.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSDataController.h"
#import "NSUserDefaults+TCSNSDate.h"
#import "TCSMTLocalConstants.h"

@implementation TCSDataController

@synthesize lastUpdate = _lastUpdate;
@synthesize updateStatus = _updateStatus;
@synthesize fromServer = _fromServer;
@synthesize fromDataBase = _fromDataBase;
@synthesize failed = _failed;
@synthesize updateRate = _updateRate;

- (void)setUpdateStatus:(TCSDataControllerStatus)updateStatus
{
	if (updateStatus == TCSDataControllerStatusUpdatedFromDatabase && (_updateStatus == TCSDataControllerStatusUpdatedFromServer || _updateStatus == TCSDataControllerStatusUpdateFromServerFailed))
	{
		return;
	}

	if (updateStatus == TCSDataControllerStatusUpdatedFromServer)
	{
		_lastUpdate = [[NSDate date]timeIntervalSince1970];
	}

	_updateStatus = updateStatus;
}

- (void)getData:(TCSMTUpdateBlock)fromServer
	  gotFailed:(TCSMTUpdateBlock)gotFailed
{
    [self getData:fromServer firstFromCache:NO force:NO gotFailed:gotFailed];
}

- (void)getData:(TCSMTUpdateBlock)fromServer
          force:(BOOL)force
	  gotFailed:(TCSMTUpdateBlock)gotFailed
{
	[self getData:fromServer firstFromCache:NO force:force gotFailed:gotFailed];
}

- (void)getData:(TCSMTUpdateBlock)fromSever
 firstFromCache:(BOOL)useCache
          force:(BOOL)force
	  gotFailed:(TCSMTUpdateBlock)gotFailed
{
	[self getDataForce:force fromDataBase:useCache ? fromSever : nil fromServer:fromSever gotFailed:gotFailed];
}

- (void)getDataForce:(BOOL)force
        fromDataBase:(TCSMTUpdateBlock)fromDataBase
          fromServer:(TCSMTUpdateBlock)fromSever
           gotFailed:(TCSMTUpdateBlock)gotFailed
{
	_fromDataBase = fromDataBase;
	_fromServer = fromSever;
	_failed = gotFailed;

    [self setUpdateStatus:TCSDataControllerStatusLoading];
    
	[self startForce:force];
}

- (void)startForce:(BOOL)force
{
	if (_fromDataBase)
	{
		[self getDataFromDataBase];
	}

	if (_fromServer && (force || [self canProcessingRequest]))
	{
		[self requestDataFromServer];
	}
}

- (void)gotDataFromServer //call after data is ready
{
    [self gotDataFromServerWithoutLogingRequestKey];
    [NSUserDefaults standardUserDefaultsSynchronizeDate:[NSDate date] forKey:self.updateRateStorageKey];
}

- (void)gotDataFromServerWithoutLogingRequestKey
{
    [self setUpdateStatus:TCSDataControllerStatusUpdatedFromServer];
    if (_fromServer)
    {
        TCSMTUpdateBlock fromServerRef = _fromServer;
        
        _fromServer();
        
        if (fromServerRef == _fromServer)
        {
            _fromServer = nil;
            _failed = nil;
        }
    }
}

- (void)gotFailed
{
	[self setUpdateStatus:TCSDataControllerStatusUpdateFromServerFailed];
	if (_failed)
	{
        TCSMTUpdateBlock failedRef = _failed;
        
		_failed();
        
        if (failedRef == _failed)
        {
            _failed = nil;
            _fromServer = nil;
            _fromDataBase = nil;
        }
	}
}

- (void)gotDataFromDataBase //call after data is ready
{
	[self setUpdateStatus:TCSDataControllerStatusUpdatedFromDatabase];

	if (_fromDataBase)
	{
        TCSMTUpdateBlock fromDataBaseRef = _fromDataBase;
        
		_fromDataBase();
        
        if (_fromDataBase == fromDataBaseRef)
        {
            _fromDataBase = nil;
            _failed = nil;
        }
	}
}


//to overwrite
- (void)getDataFromDataBase
{
	//
}

- (void)requestDataFromServer
{
    //
}

- (void)clearData
{
    
}

- (BOOL)isDataAvaliable
{
    return _lastUpdate > 0;
}

- (NSString *)updateRateStorageKey
{
    return NSStringFromClass([self class]);
}

- (BOOL)canProcessingRequest
{
    if (![self isDataAvaliable]) // если нет данных то отправляем запрос в любом случае
    {
        return YES;
    }
    
    if (self.updateRate == TCSDataControllerUpdateRateImmediately) // для этого типа updateRate отправляем запрос всегда
    {
        return YES;
    }
    
    BOOL canProcessingRequest = NO;
    
    NSDate * const lastRequestDate = [NSUserDefaults standardUserDefaultsDateForKey:self.updateRateStorageKey];
    
    NSInteger diffBetweenLastRequestAndNowInSeconds = (NSInteger)fabs(lastRequestDate.timeIntervalSinceNow);
    
    switch (self.updateRate)
    {
        case TCSDataControllerUpdateRateHourly:
            canProcessingRequest = diffBetweenLastRequestAndNowInSeconds > kUpdateRateHourlyDuration;
            break;
            
        case TCSDataControllerUpdateRateDaily:
            canProcessingRequest = diffBetweenLastRequestAndNowInSeconds > kUpdateRateDailyDuration;
            break;
            
        case TCSDataControllerUpdateRateWeekly:
            canProcessingRequest = diffBetweenLastRequestAndNowInSeconds > kUpdateRateWeeklyDuration;
            break;
            
        default:
            break;
    }
    
    return canProcessingRequest;
}

@end
