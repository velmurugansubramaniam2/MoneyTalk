//
//  TCSMTSignUpController.m
//  Telegraph
//
//  Created by spb-EOrlova on 26.11.15.
//
//

#import "TCSMTSignUpController.h"
#import "TCSAuthorizationStateManager.h"
#import "TCSAPIClient+TCSAPIClient_CommonAPIRequests.h"
#import "TCSSessionController.h"
#import "UIDevice+Helpers.h"
#import "TCSTGTelegramMoneyTalkProxy.h"

@interface TCSMTSignUpController ()
@end

@implementation TCSMTSignUpController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
    }
    
    return self;
}

- (void)performSignUpWithCompletion:(void(^)(NSError *error))completion
{
    [TCSAPIClient sharedInstance].configuration = [TCSAPIClient sharedInstance];
    TGUser *selfUser = [TCSTGTelegramMoneyTalkProxy selfUser];
    
    __weak __typeof(self) weakSelf = self;
    
    void (^apiCompletion)(NSString*, NSError*) = ^(NSString *sessionId, NSError *error)
    {
        __strong __typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf)
        {
            if (error == nil)
            {
                [[[TCSAuthorizationStateManager sharedInstance] sessionController] setTemporarySessionId:sessionId];
                [strongSelf apiSignUpWithPhoneNumber:selfUser.phoneNumber deviceId:[UIDevice deviceId] sessionId:sessionId completion:^(NSError *error)
                {
                    if (error)
                    {
                        completion(error);
                    }
                }];
            }
            else
            {
                completion(error);
            }
        }
    };
    
    [[TCSAPIClient sharedInstance] api_sessionOnCompletion:apiCompletion];

}

- (void)apiSignUpWithPhoneNumber:(NSString *)phone
                        deviceId:(NSString *)deviceId
                       sessionId:(NSString *)__unused sessionId
                      completion:(void(^)(NSError *))completion
{
    __unused NSString *phoneString = phone.copy;
    
    __weak __typeof(self) weakSelf = self;
    [[TCSAPIClient sharedInstance] api_signUpWithPhoneNumber:phone
                                                    deviceId:deviceId
                                                     success:^(TCSSession *session)
     {
         __strong __typeof(weakSelf) strongSelf = weakSelf;
         if (strongSelf)
         {
             NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
             [standardUserDefaults setObject:phone forKey:@"userDataPhoneNumber"];
             [standardUserDefaults synchronize];
             
             TCSSessionController *sessionController = [TCSAuthorizationStateManager sharedInstance].sessionController;
             [sessionController setSession:session withEncryptionKey:nil];
             
             [TCSAuthorizationStateManager sharedInstance].currentAuthorizationState = TCSAuthorizationStateSetPinCode;
         }
     }
                                                     failure:^(__unused NSError *error)
     {
         completion(error);
     }];
}

@end
