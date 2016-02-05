//
//  TCSDataController.h
//  TCSMT
//
//  Created by a.v.kiselev on 25.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^TCSMTUpdateBlock)();


typedef enum {
	TCSDataControllerStatusNotUpdated = 0,
	TCSDataControllerStatusUpdatedFromDatabase,
	TCSDataControllerStatusUpdatedFromServer,
	TCSDataControllerStatusUpdateFromServerFailed,
    TCSDataControllerStatusLoading
}TCSDataControllerStatus;

typedef NS_ENUM(NSInteger, TCSDataControllerUpdateRate)
{
    TCSDataControllerUpdateRateImmediately = 0,
    TCSDataControllerUpdateRateHourly,
    TCSDataControllerUpdateRateDaily,
    TCSDataControllerUpdateRateWeekly
};

@interface TCSDataController : NSObject
{
	NSTimeInterval						_lastUpdate;
	TCSDataControllerStatus				_updateStatus;
    
    TCSMTUpdateBlock _fromDataBase;
    TCSMTUpdateBlock _fromServer;
    TCSMTUpdateBlock _failed;
}

@property (nonatomic, readonly) NSTimeInterval lastUpdate;
@property (nonatomic, readonly) TCSDataControllerStatus updateStatus;
@property (nonatomic, strong) TCSMTUpdateBlock fromDataBase;
@property (nonatomic, strong) TCSMTUpdateBlock fromServer;
@property (nonatomic, strong) TCSMTUpdateBlock failed;

@property (nonatomic, assign) TCSDataControllerUpdateRate updateRate;

- (void)getData:(TCSMTUpdateBlock)fromServer
	  gotFailed:(TCSMTUpdateBlock)gotFailed;

- (void)getData:(TCSMTUpdateBlock)fromServer
          force:(BOOL)force
	  gotFailed:(TCSMTUpdateBlock)gotFailed;

- (void)getData:(TCSMTUpdateBlock)fromSever
 firstFromCache:(BOOL)useCache
          force:(BOOL)force
	  gotFailed:(TCSMTUpdateBlock)gotFailed;

- (void)setUpdateStatus:(TCSDataControllerStatus)updateStatus;

- (void)startForce:(BOOL)force;
- (void)gotDataFromDataBase;
- (void)gotDataFromServer;
- (void)gotFailed;

//to overwrite
- (void)getDataFromDataBase;
- (void)requestDataFromServer;

- (void)clearData;

- (NSString *)updateRateStorageKey;
- (BOOL)isDataAvaliable;
- (BOOL)canProcessingRequest;

@end
