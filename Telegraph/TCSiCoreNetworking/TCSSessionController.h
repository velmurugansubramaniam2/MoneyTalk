//
//  TCSMTSessionDataController.h
//  MT
//
//  Created by a.v.kiselev on 23/10/14.
//  Copyright (c) 2014 “Tinkoff Credit Systems” Bank (closed joint-stock company). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCSSession.h"

extern NSString *const TCSOldSessionIdKey;
extern NSString *const TCSSessionKey;
extern NSString *const TCSPinHashKey;

extern NSString *const TCSNotificationSessionExpired;
extern NSString *const TCSNotificationSessionReceived;


@interface TCSSessionController : NSObject

@property (nonatomic, strong) NSString * temporarySessionId;
@property (nonatomic, readonly) NSString * sessionId;

- (void)clearSessionData;
- (void)clearOldAndRelevantSessionData;
- (void)updateSessionTimerFromPing;

- (void)setSession:(TCSSession *)session withEncryptionKey:(NSString *)encryptionKey;
- (void)updateOldSessionIdWithNewEncryptionKey:(NSString *)encryptionKey;
- (NSString *)oldSessionIdWithDecryptionKey:(NSString *)decryptionKey;

- (BOOL)isOldSessionIdExists;
- (BOOL)isCurrenSessionIdExistsAndRelevant;

@end
