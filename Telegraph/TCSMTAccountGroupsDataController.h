//
//  TCSMTAccountsController.h
//  TCSMT
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSDataController.h"
#import "TCSiCoreNetworking.h"

extern NSString *const kNotificationAccountsUpdateFailed;
extern NSString *const kNotificationAccountsUpdated;

@interface TCSMTAccountGroupsDataController : TCSDataController

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) TCSAccountGroupsList *groupsList;

- (void)requestDataFromServer;

//- (BOOL)hasLessThanMaximumExternalCards;

- (void)updateAccountsAndPerformBlockWithAccountsGroupsList:(void(^)(TCSAccountGroupsList *accountGroupsList))block;
- (void)clearData;

@end
