//
//  TCSMTAccountsController.m
//  TCSMT
//
//  Created by a.v.kiselev on 31.07.13.
//  Copyright (c) 2013 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import "TCSMTAccountGroupsDataController.h"
#import "TCSAPIClient.h"
#import "TCSParseResponseHandler.h"

NSString *const kNotificationAccountsUpdateFailed = @"kNotificationAccountsUpdateFailed";
NSString *const kNotificationAccountsUpdated = @"kNotificationAccountsUpdated";

@interface TCSMTAccountGroupsDataController ()

@property (nonatomic, strong) TCSAccountGroupsList *accountGroupList;

@end

@implementation TCSMTAccountGroupsDataController

@dynamic groupsList;

@synthesize accountGroupList = _accountGroupList;

- (TCSAccountGroupsList *)groupsList {
    return _accountGroupList;
}

static TCSMTAccountGroupsDataController * __sharedInstance = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        __sharedInstance = [[self alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:__sharedInstance selector:@selector(requestDataFromServer) name:TCSNotificationBalanceAffected object:nil];
    });

	return __sharedInstance;
}

- (void)requestDataFromServer 
{
    __weak __typeof(self) weakSelf = self;

    void (^failure)(NSError *) = ^(NSError *error)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf gotFailed];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAccountsUpdateFailed object:self userInfo:@{kNotificationAccountsUpdateFailed : error}];
        }
    };

    void (^success)(TCSAccountGroupsList *) = ^(TCSAccountGroupsList * groupsList)
    {
        void (^responseProcessBlock)() = ^ {
            __strong __typeof(weakSelf) strongSelf = weakSelf;
            if (strongSelf)
            {
                strongSelf.accountGroupList = groupsList;
            }

            void (^notifyBlock)() = ^
            {
                if (strongSelf)
                {
                    [strongSelf gotDataFromServer];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAccountsUpdated object:self];
                }
            };

            dispatch_async(dispatch_get_main_queue(), notifyBlock);
        };
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), responseProcessBlock);
    };

    [[TCSAPIClient sharedInstance] api_accountsListSuccess:success failure:failure];
}

- (void)clearData
{
    _accountGroupList = nil;
}

- (void)updateAccountsAndPerformBlockWithAccountsGroupsList:(void (^)(TCSAccountGroupsList *))block
{
	__weak __typeof(self) weakSelf = self;

	void (^toPerformBlock)() = ^
	{
		TCSAccountGroupsList *list = weakSelf.accountGroupList;

		if(block)
		{
			block(list);
		}
	};

	[self getData:toPerformBlock gotFailed:toPerformBlock];
}

//- (BOOL)hasLessThanMaximumExternalCards
//{
//    return ([[[self groupsList] externalCards] count] < (NSUInteger)[TCSMTConfigManager sharedInstance].config.mtAttachedCardLimit.intValue);//1);//
//}

@end
