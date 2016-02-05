//
//  TCSMTSignUpViewController.h
//  Telegraph
//
//  Created by spb-EOrlova on 26.11.15.
//
//

#import <Foundation/Foundation.h>

@interface TCSMTSignUpController : NSObject

- (void)performSignUpWithCompletion:(void(^)(NSError *error))completion;

@end
